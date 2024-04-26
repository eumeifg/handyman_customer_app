import 'package:sun3ah_customer/component/back_widget.dart';
import 'package:sun3ah_customer/component/background_component.dart';
import 'package:sun3ah_customer/component/loader_widget.dart';
import 'package:sun3ah_customer/main.dart';
import 'package:sun3ah_customer/model/service_detail_response.dart';
import 'package:sun3ah_customer/network/rest_apis.dart';
import 'package:sun3ah_customer/screens/review/review_widget.dart';
import 'package:sun3ah_customer/utils/constant.dart';
import 'package:sun3ah_customer/utils/model_keys.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class RatingViewAllScreen extends StatelessWidget {
  final List<RatingData>? ratingData;
  final int? serviceId;
  final int? handymanId;

  RatingViewAllScreen({this.ratingData, this.serviceId, this.handymanId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(language.review, color: context.primaryColor, textColor: Colors.white, backWidget: BackWidget()),
      body: SnapHelperWidget<List<RatingData>>(
        future: serviceId != null ? serviceReviews({CommonKeys.serviceId: serviceId}) : handymanReviews({CommonKeys.handymanId: handymanId}),
        loadingWidget: LoaderWidget(),
        onSuccess: (data) {
          if (data.isNotEmpty) {
            return AnimatedListView(
              slideConfiguration: sliderConfigurationGlobal,
              shrinkWrap: true,
              padding: EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (context, index) => ReviewWidget(data: data[index], isCustomer: serviceId == null),
            );
          } else {
            return BackgroundComponent(text: language.lblNoServiceRatings);
          }
        },
      ),
    );
  }
}
