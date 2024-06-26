import 'package:sun3ah_customer/app_theme.dart';
import 'package:sun3ah_customer/component/base_scaffold_widget.dart';
import 'package:sun3ah_customer/component/loader_widget.dart';
import 'package:sun3ah_customer/main.dart';
import 'package:sun3ah_customer/model/post_job_detail_response.dart';
import 'package:sun3ah_customer/network/rest_apis.dart';
import 'package:sun3ah_customer/screens/dashboard/dashboard_screen.dart';
import 'package:sun3ah_customer/screens/map/map_screen.dart';
import 'package:sun3ah_customer/services/location_service.dart';
import 'package:sun3ah_customer/utils/common.dart';
import 'package:sun3ah_customer/utils/constant.dart';
import 'package:sun3ah_customer/utils/images.dart';
import 'package:sun3ah_customer/utils/model_keys.dart';
import 'package:sun3ah_customer/utils/permissions.dart';
import 'package:sun3ah_customer/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

class BookPostJobRequestScreen extends StatefulWidget {

  final PostJobDetailResponse postJobDetailResponse;
  final num? providerId;
  final num? jobPrice;

  BookPostJobRequestScreen({required this.postJobDetailResponse, required this.providerId,this.jobPrice});

  @override
  _BookPostJobRequestScreenState createState() => _BookPostJobRequestScreenState();
}

class _BookPostJobRequestScreenState extends State<BookPostJobRequestScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController dateTimeCont = TextEditingController();
  TextEditingController addressCont = TextEditingController();

  DateTime currentDateTime = DateTime.now();
  DateTime? selectedDate;
  DateTime? finalDate;
  TimeOfDay? pickedTime;

  double amount = 0;
  double totalAmount = 0;

  num? serviceId;
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  void selectDateAndTime(BuildContext context) async {
    await showDatePicker(
      context: context,
      initialDate: selectedDate ?? currentDateTime,
      firstDate: currentDateTime,
      lastDate: currentDateTime.add(30.days),
      locale: Locale(appStore.selectedLanguageCode),
      builder: (_, child) {
        return Theme(
          data: appStore.isDarkMode ? ThemeData.dark() : AppTheme.lightTheme(),
          child: child!,
        );
      },
    ).then((date) async {
      if (date != null) {
        await showTimePicker(
          context: context,
          initialTime: pickedTime ?? TimeOfDay.now(),
          builder: (_, child) {
            return Theme(
              data: appStore.isDarkMode ? ThemeData.dark() : AppTheme.lightTheme(),
              child: child!,
            );
          },
        ).then((time) {
          if (time != null) {
            finalDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);

            DateTime now = DateTime.now().subtract(1.minutes);
            if (date.isToday && finalDate!.millisecondsSinceEpoch < now.millisecondsSinceEpoch) {
              return toast(language.selectedBookingTimeIsAlreadyPassed);
            }

            selectedDate = date;
            pickedTime = time;
            dateTimeCont.text = "${formatDate(selectedDate.toString(), format: DATE_FORMAT_3)} ${pickedTime!.format(context).toString()}";
          }
        }).catchError((e) {
          toast(e.toString());
        });
      }
    });
  }

  void _handleSetLocationClick() {
    Permissions.cameraFilesAndLocationPermissionsGranted().then((value) async {
      await setValue(PERMISSION_STATUS, value);

      if (value) {
        String? res = await MapScreen(latitude: getDoubleAsync(LATITUDE), latLong: getDoubleAsync(LONGITUDE)).launch(context);

        if (res != null) {
          addressCont.text = res;
          setState(() {});
        }
      }
    });
  }

  void _handleCurrentLocationClick() {
    Permissions.cameraFilesAndLocationPermissionsGranted().then((value) async {
      await setValue(PERMISSION_STATUS, value);

      if (value) {
        appStore.setLoading(true);

        await getUserLocation().then((value) {
          addressCont.text = value;
          setState(() {});
        }).catchError((e) {
          log(e);
          toast(e.toString());
        });

        appStore.setLoading(false);
      }
    }).catchError((e) {
      //
    });
  }

  void bookTheServiceClick() {
    showInDialog(
      context,
      builder: (p0) {
        return Observer(
          builder: (context) {
            return Container(
              width: context.width(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(ic_confirm_check, height: 100, width: 100, color: context.primaryColor),
                  24.height,
                  Text(language.lblConfirmBooking, style: boldTextStyle(size: 20)),
                  16.height,
                  Text(language.lblConfirmMsg, style: primaryTextStyle(), textAlign: TextAlign.center),
                  16.height,
                  Row(
                    children: [
                      AppButton(
                        onTap: () {
                          finish(context);
                        },
                        text: language.lblCancel,
                        textColor: textPrimaryColorGlobal,
                      ).expand(),
                      16.width,
                      AppButton(
                        text: language.confirm,
                        textColor: Colors.white,
                        color: context.primaryColor,
                        onTap: () {
                          hideKeyboard(context);

                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            bookServices();
                          }
                        },
                      ).expand(),
                    ],
                  )
                ],
              ).visible(
                !appStore.isLoading,
                defaultWidget: LoaderWidget().withSize(width: 250, height: 280),
              ),
            );
          },
        );
      },
    );
  }

  void bookServices() {
    if(widget.postJobDetailResponse.postRequestDetail != null && widget.postJobDetailResponse.postRequestDetail!.service.validate().isNotEmpty) {
      serviceId = widget.postJobDetailResponse.postRequestDetail!.service!.first.id.validate();
    }

    log(widget.postJobDetailResponse.postRequestDetail!.toJson());

    Map request = {
      CommonKeys.id: "",
      PostJob.postRequestId: widget.postJobDetailResponse.postRequestDetail!.id.validate(),
      CommonKeys.serviceId: serviceId,
      CommonKeys.providerId: widget.providerId.toString(),
      CommonKeys.customerId: appStore.userId.toString().toString(),
      CommonKeys.status: BookingStatusKeys.accept,
      CommonKeys.address: addressCont.text.validate(),
      CommonKeys.date: dateTimeCont.text,
      BookService.amount: widget.postJobDetailResponse.postRequestDetail!.jobPrice.validate(),
      BookingServiceKeys.totalAmount: widget.postJobDetailResponse.postRequestDetail!.jobPrice.validate(),
      BookingServiceKeys.type: BOOKING_TYPE_USER_POST_JOB,
      BookingServiceKeys.couponId: '',
      BookingServiceKeys.description: '',
    };

    appStore.setLoading(true);

    bookTheServices(request).then((value) {
      appStore.setLoading(false);

      DashboardScreen(redirectToBooking: true).launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.bookTheService,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(language.lblDateAndTime, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                    8.height,
                    AppTextField(
                      textFieldType: TextFieldType.OTHER,
                      controller: dateTimeCont,
                      isValidationRequired: true,
                      validator: (value) {
                        if (value!.isEmpty) return language.requiredText;
                        return null;
                      },
                      readOnly: true,
                      onTap: () {
                        selectDateAndTime(context);
                      },
                      decoration: inputDecoration(context, prefixIcon: ic_calendar.iconImage(size: 10).paddingAll(14)).copyWith(
                        fillColor: context.cardColor,
                        filled: true,
                        hintText: language.lblEnterDateAndTime,
                        hintStyle: secondaryTextStyle(),
                      ),
                    ),
                    20.height,
                    Text(language.lblYourAddress, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                    8.height,
                    AppTextField(
                      textFieldType: TextFieldType.MULTILINE,
                      controller: addressCont,
                      maxLines: 2,
                      onChanged: (s) {
                        log(s);
                      },
                      minLines: 4,
                      validator: (value) {
                        if (value!.isEmpty) return language.requiredText;
                        return null;
                      },
                      isValidationRequired: true,
                      decoration: inputDecoration(
                        context,
                        prefixIcon: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ic_location.iconImage(size: 22).paddingOnly(top: 8),
                          ],
                        ),
                      ).copyWith(
                        fillColor: context.cardColor,
                        filled: true,
                        hintText: language.lblEnterYourAddress,
                        hintStyle: secondaryTextStyle(),
                      ),
                    ),
                    8.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          child: Text(language.lblChooseFromMap, style: boldTextStyle(color: context.primaryColor, size: 13)),
                          onPressed: () {
                            _handleSetLocationClick();
                          },
                        ).flexible(),
                        TextButton(
                          onPressed: _handleCurrentLocationClick,
                          child: Text(language.lblUseCurrentLocation, style: boldTextStyle(color: context.primaryColor, size: 13)),
                        ).flexible(),
                      ],
                    ),
                    16.height,
                    AppButton(
                      child: Text(language.lblBookNow, style: boldTextStyle(color: white)), //
                      color: context.primaryColor,
                      width: context.width(),
                      onTap: () {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          bookTheServiceClick();
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
