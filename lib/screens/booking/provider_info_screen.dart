import 'package:sun3ah_customer/component/back_widget.dart';
import 'package:sun3ah_customer/component/loader_widget.dart';
import 'package:sun3ah_customer/component/user_info_widget.dart';
import 'package:sun3ah_customer/component/view_all_label_component.dart';
import 'package:sun3ah_customer/main.dart';
import 'package:sun3ah_customer/model/provider_info_response.dart';
import 'package:sun3ah_customer/model/service_data_model.dart';
import 'package:sun3ah_customer/network/rest_apis.dart';
import 'package:sun3ah_customer/screens/service/component/service_component.dart';
import 'package:sun3ah_customer/screens/service/search_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/colors.dart';
import '../../utils/common.dart';
import '../../utils/images.dart';

class ProviderInfoScreen extends StatefulWidget {
  final int? providerId;
  final bool canCustomerContact;
  final VoidCallback? onUpdate;

  ProviderInfoScreen({this.providerId, this.canCustomerContact = false, this.onUpdate});

  @override
  ProviderInfoScreenState createState() => ProviderInfoScreenState();
}

class ProviderInfoScreenState extends State<ProviderInfoScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget servicesWidget({required List<ServiceData> list, int? providerId}) {
    return Column(
      children: [
        ViewAllLabel(
          label: language.service,
          list: list,
          onTap: () {
            SearchListScreen(providerId: providerId).launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
          },
        ),
        8.height,
        AnimatedWrap(
          spacing: 16,
          runSpacing: 16,
          itemCount: list.length,
          scaleConfiguration: ScaleConfiguration(duration: 300.milliseconds, delay: 50.milliseconds),
          itemBuilder: (_, index) => ServiceComponent(serviceData: list[index], width: context.width()),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProviderInfoResponse>(
      future: getProviderDetail(widget.providerId.validate(), userId: appStore.userId.validate()),
      builder: (context, snap) {
        return WillPopScope(
          onWillPop: () {
            finish(context);
            widget.onUpdate?.call();
            return Future.value(true);
          },
          child: Scaffold(
            body: snap.hasData
                ? Stack(
                    children: [
                      if (snap.data!.userData != null)
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: context.statusBarHeight),
                                color: context.primaryColor,
                                child: Row(
                                  children: [
                                    BackWidget(onPressed: () {
                                      finish(context);
                                      widget.onUpdate?.call();
                                    }),
                                    16.width,
                                    Text(language.lblAboutProvider, style: boldTextStyle(color: Colors.white, size: 20)),
                                  ],
                                ),
                              ),
                              UserInfoWidget(
                                data: snap.data!.userData!,
                                isOnTapEnabled: true,
                                onUpdate: () {
                                  widget.onUpdate?.call();
                                },
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (snap.data!.userData!.knownLanguagesArray.isNotEmpty)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(language.knownLanguages, style: boldTextStyle()),
                                        8.height,
                                        Wrap(
                                          children: snap.data!.userData!.knownLanguagesArray.map((e) {
                                            return Container(
                                              decoration: boxDecorationWithRoundedCorners(
                                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                                backgroundColor: appStore.isDarkMode ? cardDarkColor : primaryColor.withOpacity(0.1),
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              margin: EdgeInsets.all(4),
                                              child: Text(e, style: secondaryTextStyle(size: 12, weight: FontWeight.bold)),
                                            );
                                          }).toList(),
                                        ),
                                        16.height,
                                      ],
                                    ),
                                  if (snap.data!.userData!.skillsArray.isNotEmpty)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(language.essentialSkills, style: boldTextStyle()),
                                        8.height,
                                        Wrap(
                                          children: snap.data!.userData!.skillsArray.map((e) {
                                            return Container(
                                              decoration: boxDecorationWithRoundedCorners(
                                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                                backgroundColor: appStore.isDarkMode ? cardDarkColor : primaryColor.withOpacity(0.1),
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              margin: EdgeInsets.all(4),
                                              child: Text(e, style: secondaryTextStyle(size: 12, weight: FontWeight.bold)),
                                            );
                                          }).toList(),
                                        ),
                                        16.height,
                                      ],
                                    ),
                                  if (snap.data!.userData!.description != null)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(language.lblAboutProvider, style: boldTextStyle()),
                                        8.height,
                                        Text(snap.data!.userData!.description.validate(), style: secondaryTextStyle()),
                                        16.height,
                                      ],
                                    ),
                                  if (widget.canCustomerContact)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(language.personalInfo, style: boldTextStyle()),
                                        8.height,
                                        TextIcon(
                                          spacing: 10,
                                          onTap: () {
                                            launchMail("${snap.data!.userData!.email.validate()}");
                                          },
                                          prefix: Image.asset(ic_message, width: 16, height: 16, color: appStore.isDarkMode ? Colors.white : context.primaryColor),
                                          text: snap.data!.userData!.email.validate(),
                                          textStyle: secondaryTextStyle(size: 16),
                                          expandedText: true,
                                        ),
                                        4.height,
                                        TextIcon(
                                          spacing: 10,
                                          onTap: () {
                                            launchCall("${snap.data!.userData!.contactNumber.validate()}");
                                          },
                                          prefix: Image.asset(ic_calling, width: 16, height: 16, color: appStore.isDarkMode ? Colors.white : context.primaryColor),
                                          text: snap.data!.userData!.contactNumber.validate(),
                                          textStyle: secondaryTextStyle(size: 16),
                                          expandedText: true,
                                        ),
                                        8.height,
                                      ],
                                    ),
                                  servicesWidget(list: snap.data!.serviceList!, providerId: widget.providerId.validate()),
                                ],
                              ).paddingAll(16),
                            ],
                          ),
                        ),
                    ],
                  )
                : LoaderWidget(),
          ),
        );
      },
    );
  }
}
