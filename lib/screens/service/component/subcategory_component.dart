import 'package:sun3ah_customer/component/cached_image_widget.dart';
import 'package:sun3ah_customer/main.dart';
import 'package:sun3ah_customer/model/category_model.dart';
import 'package:sun3ah_customer/network/rest_apis.dart';
import 'package:sun3ah_customer/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nb_utils/nb_utils.dart';

class SubCategoryComponent extends StatefulWidget {
  final int? catId;
  final Function(bool val) onDataLoaded;

  SubCategoryComponent({required this.catId, required this.onDataLoaded});

  @override
  _SubCategoryComponentState createState() => _SubCategoryComponentState();
}

class _SubCategoryComponentState extends State<SubCategoryComponent> {
  Future<CategoryResponse>? future;

  CategoryData allValue = CategoryData(id: -1, name: language.lblAll);

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = getSubCategoryList(catId: widget.catId.validate());
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CategoryResponse>(
      future: future,
      builder: (context, snap) {
        if (snap.hasData) {
          if (snap.data!.categoryList!.isEmpty) {
            widget.onDataLoaded.call(false);
            return Offstage();
          } else {
            if (!snap.data!.categoryList!.any((element) => element.id == allValue.id)) {
              snap.data!.categoryList!.insert(0, allValue);
            }
            widget.onDataLoaded.call(true);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.height,
                Text(language.lblSubcategories, style: boldTextStyle(size: LABEL_TEXT_SIZE)).paddingLeft(16),
                HorizontalList(
                  itemCount: snap.data!.categoryList.validate().length,
                  padding: EdgeInsets.only(left: 16, right: 16),
                  runSpacing: 8,
                  spacing: 12,
                  itemBuilder: (_, index) {
                    CategoryData data = snap.data!.categoryList![index];

                    return Observer(
                      builder: (_) {
                        bool isSelected = filterStore.selectedSubCategoryId == index;

                        return GestureDetector(
                          onTap: () {
                            filterStore.setSelectedSubCategory(catId: index);
                            LiveStream().emit(LIVESTREAM_UPDATE_SERVICE_LIST, data.id.validate());
                          },
                          child: SizedBox(
                            width: context.width() / 4 - 20,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Column(
                                  children: [
                                    16.height,
                                    if (index == 0)
                                      Container(
                                        height: CATEGORY_ICON_SIZE,
                                        width: CATEGORY_ICON_SIZE,
                                        decoration: BoxDecoration(color: context.cardColor, shape: BoxShape.circle, border: Border.all(color: grey)),
                                        alignment: Alignment.center,
                                        child: Text(data.name.validate(), style: boldTextStyle(size: 14)),
                                      ),
                                    if (index != 0)
                                      data.categoryImage.validate().endsWith('.svg')
                                          ? Container(
                                              width: CATEGORY_ICON_SIZE,
                                              height: CATEGORY_ICON_SIZE,
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(color: context.cardColor, shape: BoxShape.circle),
                                              child: SvgPicture.network(
                                                data.categoryImage.validate(),
                                                height: CATEGORY_ICON_SIZE,
                                                width: CATEGORY_ICON_SIZE,

                                                /// TODO Add Comment code after Subcategory image
                                                //color: appStore.isDarkMode ? Colors.white : data.color.validate(value: '000').toColor(),
                                                placeholderBuilder: (context) => PlaceHolderWidget(height: CATEGORY_ICON_SIZE, width: CATEGORY_ICON_SIZE, color: transparentColor),
                                              ),
                                            )
                                          : Container(
                                              decoration: BoxDecoration(color: context.cardColor, shape: BoxShape.circle),
                                              child: CachedImageWidget(
                                                url: data.categoryImage.validate(),
                                                fit: BoxFit.cover,
                                                width: CATEGORY_ICON_SIZE,
                                                height: CATEGORY_ICON_SIZE,
                                                circle: true,
                                              ),
                                            ),
                                    4.height,
                                    if (index == 0) Text(language.lblViewAll, style: boldTextStyle(size: 12), textAlign: TextAlign.center, maxLines: 1),
                                    if (index != 0) Marquee(child: Text('${data.name.validate()}', style: boldTextStyle(size: 12), textAlign: TextAlign.center, maxLines: 1)),
                                  ],
                                ),
                                Positioned(
                                  top: 14,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: boxDecorationDefault(color: context.primaryColor),
                                    child: Icon(Icons.done, size: 16, color: Colors.white),
                                  ).visible(isSelected),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            );
          }
        }

        return snapWidgetHelper(snap, loadingWidget: Offstage());
      },
    );
  }
}
