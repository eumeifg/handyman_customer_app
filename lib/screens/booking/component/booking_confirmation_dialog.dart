import 'package:sun3ah_customer/model/package_data_model.dart';
import 'package:sun3ah_customer/screens/booking/booking_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/price_widget.dart';
import '../../../main.dart';
import '../../../model/service_detail_response.dart';
import '../../../utils/colors.dart';
import '../../../utils/common.dart';
import '../../../utils/constant.dart';
import '../../dashboard/dashboard_screen.dart';

class BookingConfirmationDialog extends StatefulWidget {
  final ServiceDetailResponse data;
  final int? bookingId;
  final num? bookingPrice;
  final BookingPackage? selectedPackage;
  final CouponData? appliedCouponData;

  BookingConfirmationDialog({
    required this.data,
    required this.bookingId,
    this.bookingPrice,
    this.selectedPackage,
    this.appliedCouponData,
  });

  @override
  State<BookingConfirmationDialog> createState() => _BookingConfirmationDialogState();
}

class _BookingConfirmationDialogState extends State<BookingConfirmationDialog> {
  int itemCount = 1;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  Widget buildDateWidget() {
    if (widget.data.serviceDetail!.isSlotAvailable) {
      return Text(formatDate(widget.data.serviceDetail!.bookingDate.validate(), format: DATE_FORMAT_2), style: boldTextStyle(size: 16));
    }
    return Text(formatDate(widget.data.serviceDetail!.dateTimeVal.validate(), format: DATE_FORMAT_2), style: boldTextStyle(size: 16));
  }

  Widget buildTimeWidget() {
    if (widget.data.serviceDetail!.bookingSlot == null) {
      return Text(formatDate(widget.data.serviceDetail!.dateTimeVal.validate(), format: HOUR_12_FORMAT), style: boldTextStyle(size: 16), textAlign: TextAlign.end);
    }
    return Text(
      TimeOfDay(
        hour: widget.data.serviceDetail!.bookingSlot.validate().splitBefore(':').split(":").first.toInt(),
        minute: widget.data.serviceDetail!.bookingSlot.validate().splitBefore(':').split(":").last.toInt(),
      ).format(context),
      style: boldTextStyle(size: 16),
      textAlign: TextAlign.end,
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width(),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: radius(),
            ),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(top: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                30.height,
                Text(language.thankYou, style: boldTextStyle(size: 20)),
                8.height,
                Text(language.bookingConfirmedMsg, style: secondaryTextStyle()),
                24.height,
                DottedBorderWidget(
                  color: primaryColor.withOpacity(0.6),
                  strokeWidth: 1,
                  gap: 6,
                  padding: EdgeInsets.all(16),
                  radius: 12,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(language.lblDate, style: secondaryTextStyle()),
                          Text(language.lblTime, style: secondaryTextStyle()),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildDateWidget().expand(flex: 2),
                          buildTimeWidget().expand(flex: 1),
                        ],
                      ),
                    ],
                  ).center(),
                ),
                16.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(language.totalAmount, style: secondaryTextStyle(size: 16)),
                        8.height,
                        if (widget.selectedPackage != null)
                          PriceWidget(price: widget.bookingPrice.validate(), size: 18, color: textPrimaryColorGlobal)
                        else
                          PriceWidget(
                            price: calculateTotalAmount(
                              serviceDiscountPercent: widget.data.serviceDetail!.discount.validate(),
                              qty: itemCount,
                              detail: widget.data.serviceDetail,
                              servicePrice: widget.data.serviceDetail!.price!,
                              taxes: widget.data.taxes!,
                              couponData: widget.appliedCouponData,
                            ),
                            size: 18,
                            color: textPrimaryColorGlobal,
                          ),
                      ],
                    ),
                  ],
                ),
                16.height,
                Row(
                  children: [
                    AppButton(
                      padding: EdgeInsets.zero,
                      text: language.goToHome,
                      textStyle: boldTextStyle(size: 14, color: Colors.white),
                      color: context.primaryColor,
                      onTap: () {
                        DashboardScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
                      },
                    ).expand(),
                    16.width,
                    AppButton(
                      padding: EdgeInsets.zero,
                      text: language.goToReview,
                      textStyle: boldTextStyle(size: 14),
                      shapeBorder: RoundedRectangleBorder(borderRadius: radius(), side: BorderSide(color: primaryColor)),
                      color: context.scaffoldBackgroundColor,
                      onTap: () {
                        DashboardScreen(redirectToBooking: true).launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
                        BookingDetailScreen(bookingId: widget.bookingId.validate()).launch(context);
                      },
                    ).expand(),
                  ],
                ),
                16.height,
              ],
            ),
          ),
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.primaryColor,
              border: Border.all(width: 5, color: context.cardColor, style: BorderStyle.solid, strokeAlign: BorderSide.strokeAlignOutside),
            ),
            child: Icon(Icons.check, color: context.cardColor, size: 40),
          ),
        ],
      ),
    );
  }
}
