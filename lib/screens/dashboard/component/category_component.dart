import 'package:sun3ah_customer/component/view_all_label_component.dart';
import 'package:sun3ah_customer/main.dart';
import 'package:sun3ah_customer/model/category_model.dart';
import 'package:sun3ah_customer/screens/category/category_screen.dart';
import 'package:sun3ah_customer/screens/dashboard/component/category_widget.dart';
import 'package:sun3ah_customer/screens/service/search_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class CategoryComponent extends StatefulWidget {
  final List<CategoryData>? categoryList;

  CategoryComponent({this.categoryList});

  @override
  CategoryComponentState createState() => CategoryComponentState();
}

class CategoryComponentState extends State<CategoryComponent> {
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

  @override
  Widget build(BuildContext context) {
    if (widget.categoryList.validate().isEmpty) return Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ViewAllLabel(
          label: language.category,
          list: widget.categoryList!,
          onTap: () {
            CategoryScreen().launch(context).then((value) {
              setStatusBarColor(Colors.transparent);
            });
          },
        ).paddingSymmetric(horizontal: 16),
        HorizontalList(
          itemCount: widget.categoryList.validate().length,
          padding: EdgeInsets.only(left: 16, right: 16),
          runSpacing: 8,
          spacing: 12,
          itemBuilder: (_, i) {
            CategoryData data = widget.categoryList![i];
            return GestureDetector(
              onTap: () {
                SearchListScreen(categoryId: data.id.validate(), categoryName: data.name, isFromCategory: true).launch(context);
              },
              child: CategoryWidget(categoryData: data),
            );
          },
        ),
      ],
    );
  }
}
