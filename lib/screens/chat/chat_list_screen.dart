import 'package:sun3ah_customer/component/back_widget.dart';
import 'package:sun3ah_customer/component/loader_widget.dart';
import 'package:sun3ah_customer/main.dart';
import 'package:sun3ah_customer/model/user_data_model.dart';
import 'package:sun3ah_customer/screens/chat/widget/user_item_widget.dart';
import 'package:sun3ah_customer/utils/constant.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/background_component.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language.lblChat,
        textColor: white,
        showBack: Navigator.canPop(context),
        elevation: 3.0,
        backWidget: BackWidget(),
        color: context.primaryColor,
      ),
      body: appStore.uid.validate().isNotEmpty
          ? FirestorePagination(
              itemBuilder: (context, snap, index) {
                UserData contact = UserData.fromJson(snap.data() as Map<String, dynamic>);

                return UserItemWidget(userUid: contact.uid.validate());
              },
              physics: AlwaysScrollableScrollPhysics(),
              query: chatServices.fetchChatListQuery(userId: appStore.uid.validate()),
              onEmpty: BackgroundComponent(
                text: language.noConversation,
                subTitle: language.noConversationSubTitle,
              ).paddingSymmetric(horizontal: 16),
              initialLoader: LoaderWidget(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 10),
              isLive: true,
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 0, top: 8, right: 0, bottom: 0),
              limit: PER_PAGE_CHAT_LIST_COUNT,
              separatorBuilder: (_, i) => Divider(height: 0, indent: 82),
              viewType: ViewType.list,
            )
          : BackgroundComponent(
              text: language.noConversation,
              subTitle: language.noConversationSubTitle,
            ).paddingSymmetric(horizontal: 16),
    );
  }
}
