import 'package:sun3ah_customer/component/base_scaffold_widget.dart';
import 'package:sun3ah_customer/component/cached_image_widget.dart';
import 'package:sun3ah_customer/component/disabled_rating_bar_widget.dart';
import 'package:sun3ah_customer/component/loader_widget.dart';
import 'package:sun3ah_customer/component/price_widget.dart';
import 'package:sun3ah_customer/component/view_all_label_component.dart';
import 'package:sun3ah_customer/main.dart';
import 'package:sun3ah_customer/model/get_my_post_job_list_response.dart';
import 'package:sun3ah_customer/model/post_job_detail_response.dart';
import 'package:sun3ah_customer/model/service_data_model.dart';
import 'package:sun3ah_customer/model/user_data_model.dart';
import 'package:sun3ah_customer/network/rest_apis.dart';
import 'package:sun3ah_customer/screens/booking/provider_info_screen.dart';
import 'package:sun3ah_customer/screens/jobRequest/book_post_job_request_screen.dart';
import 'package:sun3ah_customer/screens/jobRequest/components/bidder_item_component.dart';
import 'package:sun3ah_customer/utils/constant.dart';
import 'package:sun3ah_customer/utils/model_keys.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class MyPostDetailScreen extends StatefulWidget {
  final int postRequestId;
  final PostJobData? postJobData;
  final VoidCallback callback;

  MyPostDetailScreen({required this.postRequestId, this.postJobData, required this.callback});

  @override
  _MyPostDetailScreenState createState() => _MyPostDetailScreenState();
}

class _MyPostDetailScreenState extends State<MyPostDetailScreen> {
  Future<PostJobDetailResponse>? future;

  @override
  void initState() {
    super.initState();
    LiveStream().on(LIVESTREAM_UPDATE_BIDER, (p0) {
      init();
      setState(() {});
    });

    init();
  }

  void init() async {
    future = getPostJobDetail({PostJob.postRequestId: widget.postRequestId.validate()});
  }

  Widget titleWidget({required String title, required String detail, bool isReadMore = false, required TextStyle detailTextStyle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.validate(), style: secondaryTextStyle()),
        8.height,
        if (isReadMore) ReadMoreText(detail, style: detailTextStyle) else Text(detail.validate(), style: detailTextStyle),
        16.height,
      ],
    );
  }

  Widget postJobDetailWidget({required PostJobData data}) {
    return Container(
      padding: EdgeInsets.all(16),
      width: context.width(),
      decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor, borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.title.validate().isNotEmpty)
            titleWidget(
              title: language.postJobTitle,
              detail: data.title.validate(),
              detailTextStyle: boldTextStyle(),
            ),
          if (data.description.validate().isNotEmpty)
            titleWidget(
              title: language.postJobDescription,
              detail: data.description.validate(),
              detailTextStyle: primaryTextStyle(),
              isReadMore: true,
            ),
          Text(data.status.validate() == JOB_REQUEST_STATUS_ASSIGNED ? language.jobPrice : language.estimatedPrice, style: secondaryTextStyle()),
          8.height,
          PriceWidget(
            price: data.status.validate() == JOB_REQUEST_STATUS_ASSIGNED ? data.jobPrice.validate() : data.price.validate(),
            isHourlyService: false,
            color: textPrimaryColorGlobal,
            isFreeService: false,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget postJobServiceWidget({required List<ServiceData> serviceList}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(language.services, style: boldTextStyle(size: LABEL_TEXT_SIZE)).paddingOnly(left: 16, right: 16),
        8.height,
        AnimatedListView(
          itemCount: serviceList.length,
          padding: EdgeInsets.all(8),
          shrinkWrap: true,
          listAnimationType: ListAnimationType.FadeIn,
          itemBuilder: (_, i) {
            ServiceData data = serviceList[i];

            return Container(
              width: context.width(),
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(8),
              decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor, borderRadius: BorderRadius.all(Radius.circular(16))),
              child: Row(
                children: [
                  CachedImageWidget(
                    url: data.attachments.validate().isNotEmpty ? data.attachments!.first.validate() : "",
                    fit: BoxFit.cover,
                    height: 50,
                    width: 50,
                    radius: defaultRadius,
                  ),
                  16.width,
                  Text(data.name.validate(), style: primaryTextStyle(), maxLines: 2, overflow: TextOverflow.ellipsis).expand(),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget bidderWidget(List<BidderData> bidderList, {required PostJobDetailResponse postJobDetailResponse}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ViewAllLabel(
          label: language.bidder,
          list: bidderList,
          onTap: () {
            //
          },
        ).paddingSymmetric(horizontal: 16),
        AnimatedListView(
          itemCount: bidderList.length > 4 ? bidderList.take(4).length : bidderList.length,
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          listAnimationType: ListAnimationType.FadeIn,
          itemBuilder: (_, i) {
            return BidderItemComponent(
              data: bidderList[i],
              postRequestId: widget.postRequestId.validate(),
              postJobData: postJobDetailResponse.postRequestDetail!,
              postJobDetailResponse: postJobDetailResponse,
            );
          },
        ),
      ],
    );
  }

  Widget providerWidget(List<BidderData> bidderList, num? providerId) {
    try {
      BidderData? bidderData = bidderList.firstWhere((element) => element.providerId == appStore.userId);
      UserData? user = bidderData.provider;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          24.height,
          Text(language.assignedProvider, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
          16.height,
          InkWell(
            onTap: () {
              ProviderInfoScreen(providerId: user.id.validate()).launch(context);
            },
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor, borderRadius: BorderRadius.all(Radius.circular(16))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CachedImageWidget(
                        url: user!.profileImage.validate(),
                        fit: BoxFit.cover,
                        height: 60,
                        width: 60,
                        circle: true,
                      ),
                      8.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Marquee(
                                directionMarguee: DirectionMarguee.oneDirection,
                                child: Text(
                                  user.displayName.validate(),
                                  style: boldTextStyle(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ).expand(),
                            ],
                          ),
                          4.height,
                          if (user.email.validate().isNotEmpty)
                            Marquee(
                              directionMarguee: DirectionMarguee.oneDirection,
                              child: Text(
                                user.email.validate(),
                                style: primaryTextStyle(size: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          4.height,
                          if (user.providersServiceRating != null) DisabledRatingBarWidget(rating: user.providersServiceRating.validate()),
                        ],
                      ).expand(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ).paddingOnly(left: 16, right: 16);
    } catch (e) {
      print(e);
    }
    return Offstage();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    LiveStream().dispose(LIVESTREAM_UPDATE_BIDER);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        init();
        setState(() {});
        return await 2.seconds.delay;
      },
      child: AppScaffold(
        appBarTitle: language.myPostDetail,
        child: FutureBuilder<PostJobDetailResponse>(
          future: future,
          builder: (context, snap) {
            if (snap.hasError) {
              return Text(snap.error.toString()).center();
            } else if (snap.hasData) {
              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 60),
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        postJobDetailWidget(data: snap.data!.postRequestDetail!).paddingAll(16),
                        if (snap.data!.postRequestDetail!.service.validate().isNotEmpty) postJobServiceWidget(serviceList: snap.data!.postRequestDetail!.service.validate()),
                        if (snap.data!.postRequestDetail!.providerId != null)
                          providerWidget(
                            snap.data!.biderData.validate(),
                            snap.data!.postRequestDetail!.providerId.validate(),
                          ),
                        if (snap.data!.biderData.validate().isNotEmpty) bidderWidget(snap.data!.biderData.validate(), postJobDetailResponse: snap.data!),
                      ],
                    ),
                  ).makeRefreshable,
                  if (snap.data!.postRequestDetail!.status.validate() == JOB_REQUEST_STATUS_ASSIGNED)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: AppButton(
                        child: Text(language.bookTheService, style: boldTextStyle(color: white)),
                        color: context.primaryColor,
                        width: context.width(),
                        onTap: () async {
                          BookPostJobRequestScreen(
                            postJobDetailResponse: snap.data!,
                            providerId: snap.data!.postRequestDetail!.providerId.validate(),
                            jobPrice: snap.data!.postRequestDetail!.jobPrice.validate(),
                          ).launch(context);
                        },
                      ),
                    ),
                ],
              );
            }
            return LoaderWidget().center();
          },
        ),
      ),
    );
  }
}
