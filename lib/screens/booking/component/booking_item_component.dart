import 'package:sun3ah_customer/component/app_common_dialog.dart';
import 'package:sun3ah_customer/component/cached_image_widget.dart';
import 'package:sun3ah_customer/component/price_widget.dart';
import 'package:sun3ah_customer/main.dart';
import 'package:sun3ah_customer/model/booking_data_model.dart';
import 'package:sun3ah_customer/model/service_detail_response.dart';
import 'package:sun3ah_customer/network/rest_apis.dart';
import 'package:sun3ah_customer/screens/booking/component/booking_service_step1.dart';
import 'package:sun3ah_customer/screens/booking/component/edit_booking_service_dialog.dart';
import 'package:sun3ah_customer/utils/colors.dart';
import 'package:sun3ah_customer/utils/common.dart';
import 'package:sun3ah_customer/utils/constant.dart';
import 'package:sun3ah_customer/utils/images.dart';
import 'package:sun3ah_customer/utils/model_keys.dart';
import 'package:sun3ah_customer/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class BookingItemComponent extends StatelessWidget {
  final BookingData bookingData;

  BookingItemComponent({required this.bookingData});

  @override
  Widget build(BuildContext context) {
    Widget _buildEditBookingWidget() {
      // if (bookingData.isSlotBooking) return Offstage();
      if (bookingData.status == BookingStatusKeys.pending && DateTime.parse(bookingData.date.validate()).isAfter(DateTime.now())) {
        return IconButton(
          icon: ic_edit_square.iconImage(size: 18),
          visualDensity: VisualDensity.compact,
          onPressed: () async {
            if (bookingData.isSlotBooking) {
              BookingServiceStep1(
                data: ServiceDetailResponse(serviceDetail: (await getServiceDetails(serviceId: bookingData.serviceId.validate(), customerId: appStore.userId, fromBooking: true)).serviceDetail),
                bookingData: bookingData,
                showAppbar: true,
              ).launch(context);
            } else {
              showInDialog(
                context,
                contentPadding: EdgeInsets.zero,
                hideSoftKeyboard: true,
                backgroundColor: context.cardColor,
                builder: (p0) {
                  return AppCommonDialog(
                    title: language.lblUpdateDateAndTime,
                    child: EditBookingServiceDialog(data: bookingData),
                  );
                },
              );
            }
          },
        );
      }
      return Offstage();
    }

    String buildTimeWidget({required BookingData bookingDetail}) {
      if (bookingDetail.bookingSlot == null) {
        return formatDate(bookingDetail.date.validate(), format: HOUR_12_FORMAT);
      }
      return TimeOfDay(hour: bookingDetail.bookingSlot.validate().splitBefore(':').split(":").first.toInt(), minute: bookingDetail.bookingSlot.validate().splitBefore(':').split(":").last.toInt())
          .format(context);
    }

    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(bottom: 16),
      width: context.width(),
      decoration: BoxDecoration(border: Border.all(color: context.dividerColor), borderRadius: radius()),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (bookingData.isPackageBooking && bookingData.bookingPackage != null)
                CachedImageWidget(
                  url: bookingData.bookingPackage!.imageAttachments.validate().isNotEmpty ? bookingData.bookingPackage!.imageAttachments.validate().first.validate() : "",
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  radius: defaultRadius,
                )
              else
                CachedImageWidget(
                  url: bookingData.serviceAttachments!.isNotEmpty ? bookingData.serviceAttachments!.first.validate() : '',
                  fit: BoxFit.cover,
                  width: 80,
                  height: 80,
                  radius: defaultRadius,
                ),
              16.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: bookingData.status.validate().getPaymentStatusBackgroundColor.withOpacity(0.1),
                              borderRadius: radius(8),
                            ),
                            child: Text(
                              bookingData.statusLabel.validate(),
                              style: boldTextStyle(color: bookingData.status.validate().getPaymentStatusBackgroundColor, size: 12),
                            ),
                          ),
                          if (bookingData.isPostJob)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              margin: EdgeInsets.only(left: 4),
                              decoration: BoxDecoration(
                                color: context.primaryColor.withOpacity(0.1),
                                borderRadius: radius(8),
                              ),
                              child: Text(
                                language.postJob,
                                style: boldTextStyle(color: context.primaryColor, size: 12),
                              ),
                            ),
                          if (bookingData.isPackageBooking)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              margin: EdgeInsets.only(left: 4),
                              decoration: BoxDecoration(
                                color: context.primaryColor.withOpacity(0.1),
                                borderRadius: radius(8),
                              ),
                              child: Text(
                                language.package,
                                style: boldTextStyle(color: context.primaryColor, size: 12),
                              ),
                            ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildEditBookingWidget(),
                          Text('#${bookingData.id.validate()}', style: boldTextStyle(color: primaryColor, size: 16)),
                        ],
                      ),
                    ],
                  ),
                  4.height,
                  Marquee(
                    child: Text(bookingData.isPackageBooking ? '${bookingData.bookingPackage!.name.validate()}' : '${bookingData.serviceName.validate()}',
                        style: boldTextStyle(size: 16), overflow: TextOverflow.ellipsis, maxLines: 1),
                  ),
                  4.height,
                  if (bookingData.bookingPackage != null)
                    PriceWidget(price: bookingData.amount.validate(), size: 18, color: primaryColor)
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (bookingData.bookingType == BOOKING_TYPE_SERVICE)
                          PriceWidget(
                            isFreeService: bookingData.type.validate() == SERVICE_TYPE_FREE,
                            price: bookingData.isHourlyService
                                ? bookingData.totalAmountWithExtraCharges.validate()
                                : calculateTotalAmount(
                                    servicePrice: bookingData.amount.validate(),
                                    qty: bookingData.quantity.validate(),
                                    couponData: bookingData.couponData != null ? bookingData.couponData : null,
                                    taxes: bookingData.taxes.validate(),
                                    serviceDiscountPercent: bookingData.discount.validate(),
                                    extraCharges: bookingData.extraCharges,
                                  ),
                            color: primaryColor,
                            size: 18,
                          )
                        else
                          PriceWidget(price: bookingData.totalAmount.validate()),
                        if (bookingData.isHourlyService) Text(language.hourly, style: secondaryTextStyle()).paddingSymmetric(horizontal: 4),
                        if (!bookingData.isHourlyService) 4.width,
                        if (bookingData.discount != null && bookingData.discount != 0)
                          Row(
                            children: [
                              Text('(${bookingData.discount.validate()}%', style: boldTextStyle(size: 14, color: Colors.green)),
                              Text(' ${language.lblOff})', style: boldTextStyle(size: 14, color: Colors.green)),
                            ],
                          ),
                      ],
                    ),
                ],
              ).expand(),
            ],
          ).paddingAll(8),
          Container(
            decoration: boxDecorationWithRoundedCorners(
              backgroundColor: context.cardColor,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            margin: EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('${language.lblDate} & ${language.lblTime}', style: secondaryTextStyle()),
                    8.width,
                    Text(
                      "${formatDate(bookingData.date.validate(), format: DATE_FORMAT_2)} At " + buildTimeWidget(bookingDetail: bookingData),
                      style: boldTextStyle(size: 14),
                      maxLines: 2,
                      textAlign: TextAlign.right,
                    ).expand(),
                  ],
                ).paddingAll(8),
                if (bookingData.providerName.validate().isNotEmpty)
                  Column(
                    children: [
                      Divider(height: 0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(language.textProvider, style: secondaryTextStyle()),
                          8.width,
                          Text(bookingData.providerName.validate(), style: boldTextStyle(size: 14), textAlign: TextAlign.right).flexible(),
                        ],
                      ).paddingAll(8),
                    ],
                  ),
                if (bookingData.handyman.validate().isNotEmpty)
                  Column(
                    children: [
                      Divider(height: 0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(language.textHandyman, style: secondaryTextStyle()),
                          Text(bookingData.handyman!.validate().first.handyman!.displayName.validate(), style: boldTextStyle(size: 14)).flexible(),
                        ],
                      ).paddingAll(8),
                    ],
                  ),
                if (bookingData.paymentStatus != null && bookingData.status == BookingStatusKeys.complete)
                  Column(
                    children: [
                      Divider(height: 0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(language.paymentStatus, style: secondaryTextStyle()).expand(),
                          Text(
                            buildPaymentStatusWithMethod(bookingData.paymentStatus.validate(), bookingData.paymentMethod.validate()),
                            style: boldTextStyle(size: 14, color: bookingData.paymentStatus.validate() == SERVICE_PAYMENT_STATUS_PAID ? Colors.green : Colors.red),
                          ),
                        ],
                      ).paddingAll(8),
                    ],
                  ),
              ],
            ).paddingAll(8),
          ),
        ],
      ),
    );
  }
}
