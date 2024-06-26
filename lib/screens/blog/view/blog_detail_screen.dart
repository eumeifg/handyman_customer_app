import 'package:sun3ah_customer/component/loader_widget.dart';
import 'package:sun3ah_customer/main.dart';
import 'package:sun3ah_customer/screens/blog/blog_repository.dart';
import 'package:sun3ah_customer/screens/blog/component/blog_detail_header_component.dart';
import 'package:sun3ah_customer/screens/blog/model/blog_detail_response.dart';
import 'package:sun3ah_customer/utils/images.dart';
import 'package:sun3ah_customer/utils/model_keys.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/drop_cap.dart';

class BlogDetailScreen extends StatefulWidget {
  final int blogId;

  BlogDetailScreen({required this.blogId});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    setStatusBarColor(transparentColor, delayInMilliSeconds: 1000);
  }

  Widget buildBodyWidget(AsyncSnapshot<BlogDetailResponse> snap) {
    if (snap.hasData) {
      return SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlogDetailHeaderComponent(blogData: snap.data!.blogDetail!),
            16.height,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(snap.data!.blogDetail!.title.validate(), style: boldTextStyle(size: 24)),
                8.height,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text('${language.authorBy}: ', style: secondaryTextStyle()),
                        Text(snap.data!.blogDetail!.authorName.validate(), style: primaryTextStyle(size: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ).expand(),
                    if (snap.data!.blogDetail!.totalViews != 0)
                      Row(
                        children: [
                          Icon(Icons.remove_red_eye, size: 24, color: context.iconColor),
                          8.width,
                          Text('${snap.data!.blogDetail!.totalViews.validate()} ', style: boldTextStyle()),
                          Text(language.views, style: boldTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                  ],
                ),
                16.height,
                DropCapText(
                  snap.data!.blogDetail!.description.validate(),
                  style: primaryTextStyle(),
                ),
                //Text(snap.data!.blogDetail!.description.validate(), style: primaryTextStyle(color: textSecondaryColorGlobal)),
              ],
            ).paddingSymmetric(horizontal: 16)
          ],
        ),
      );
    }

    return snapWidgetHelper(snap, loadingWidget: LoaderWidget());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BlogDetailResponse>(
      future: getBlogDetailAPI({BlogKey.blogId: widget.blogId.validate()}),
      builder: (context, snap) {
        return Scaffold(
          body: buildBodyWidget(snap),
          floatingActionButton: (snap.hasData && snap.data!.blogDetail!.isFeatured.validate(value: 0) == 1)
              ? FloatingActionButton(
                  elevation: 0.0,
                  child: Image.asset(ic_featured, height: 22, width: 22, color: white),
                  backgroundColor: context.primaryColor,
                  onPressed: () {
                    toast(language.lblFeatured);
                  },
                )
              : Offstage(),
        );
      },
    );
  }
}
