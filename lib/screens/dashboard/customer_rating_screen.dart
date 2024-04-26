import 'package:sun3ah_customer/component/back_widget.dart';
import 'package:sun3ah_customer/component/background_component.dart';
import 'package:sun3ah_customer/main.dart';
import 'package:sun3ah_customer/screens/dashboard/component/customer_rating_widget.dart';
import 'package:sun3ah_customer/utils/constant.dart';
import 'package:sun3ah_customer/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class CustomerRatingScreen extends StatefulWidget {
  @override
  State<CustomerRatingScreen> createState() => _CustomerRatingScreenState();
}

class _CustomerRatingScreenState extends State<CustomerRatingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(language.lblReviewsOnServices, textColor: Colors.white, color: context.primaryColor, backWidget: BackWidget()),
      body: reviewData.validate().isEmpty
          ? BackgroundComponent(
              text: language.lblNoRateYet,
              image: no_rating_bar,
              subTitle: 'Tell others what you think',
            )
          : AnimatedListView(
              padding: EdgeInsets.fromLTRB(8, 16, 8, 80),
              slideConfiguration: sliderConfigurationGlobal,
              itemCount: reviewData.length,
              itemBuilder: (context, index) {
                return CustomerRatingWidget(
                  data: reviewData[index],
                  onDelete: (data) {
                    reviewData.remove(data);
                    setState(() {});
                  },
                );
              },
            ),
    );
  }
}
