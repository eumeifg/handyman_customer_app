import 'package:sun3ah_customer/component/cached_image_widget.dart';
import 'package:sun3ah_customer/component/loader_widget.dart';
import 'package:sun3ah_customer/main.dart';
import 'package:sun3ah_customer/network/rest_apis.dart';
import 'package:sun3ah_customer/screens/auth/change_password_screen.dart';
import 'package:sun3ah_customer/screens/auth/edit_profile_screen.dart';
import 'package:sun3ah_customer/screens/auth/sign_in_screen.dart';
import 'package:sun3ah_customer/screens/blog/view/blog_list_screen.dart';
import 'package:sun3ah_customer/screens/dashboard/customer_rating_screen.dart';
import 'package:sun3ah_customer/screens/dashboard/dashboard_screen.dart';
import 'package:sun3ah_customer/screens/service/favourite_service_screen.dart';
import 'package:sun3ah_customer/screens/setting_screen.dart';
import 'package:sun3ah_customer/utils/colors.dart';
import 'package:sun3ah_customer/utils/common.dart';
import 'package:sun3ah_customer/utils/configs.dart';
import 'package:sun3ah_customer/utils/constant.dart';
import 'package:sun3ah_customer/utils/images.dart';
import 'package:sun3ah_customer/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../favourite_provider_screen.dart';

class ProfileFragment extends StatefulWidget {
  @override
  ProfileFragmentState createState() => ProfileFragmentState();
}

class ProfileFragmentState extends State<ProfileFragment> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    afterBuildCreated(() {
      appStore.setLoading(false);
      setStatusBarColor(context.primaryColor);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language.profile,
        textColor: white,
        elevation: 0.0,
        color: context.primaryColor,
        showBack: false,
        actions: [
          IconButton(
            icon: ic_setting.iconImage(color: white, size: 20),
            onPressed: () async {
              SettingScreen().launch(context);
            },
          ),
        ],
      ),
      body: Observer(
        builder: (BuildContext context) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (appStore.isLoggedIn)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          24.height,
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                decoration: boxDecorationDefault(
                                  border: Border.all(color: primaryColor, width: 3),
                                  shape: BoxShape.circle,
                                ),
                                child: Container(
                                  decoration: boxDecorationDefault(
                                    border: Border.all(color: context.scaffoldBackgroundColor, width: 4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: CachedImageWidget(
                                    url: appStore.userProfileImage,
                                    height: 90,
                                    width: 90,
                                    fit: BoxFit.cover,
                                    radius: 60,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 8,
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(6),
                                  decoration: boxDecorationDefault(
                                    shape: BoxShape.circle,
                                    color: primaryColor,
                                    border: Border.all(color: context.cardColor, width: 2),
                                  ),
                                  child: Icon(AntDesign.edit, color: white, size: 18),
                                ).onTap(() {
                                  EditProfileScreen().launch(context);
                                }),
                              ),
                            ],
                          ),
                          16.height,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(appStore.userFullName, style: boldTextStyle(color: primaryColor, size: 18)),
                              Text(appStore.userEmail, style: secondaryTextStyle()),
                            ],
                          ),
                          24.height,
                        ],
                      ).center(),
                    SettingSection(
                      title: Text(language.lblGENERAL, style: boldTextStyle(color: primaryColor)),
                      headingDecoration: BoxDecoration(color: context.primaryColor.withOpacity(0.1)),
                      divider: Offstage(),
                      items: [
                        SettingItemWidget(
                          leading: ic_heart.iconImage(size: SETTING_ICON_SIZE),
                          title: language.lblFavorite,
                          trailing: trailing,
                          onTap: () {
                            doIfLoggedIn(context, () {
                              FavouriteServiceScreen().launch(context);
                            });
                          },
                        ),
                        SettingItemWidget(
                          leading: ic_heart.iconImage(size: SETTING_ICON_SIZE),
                          title: language.favouriteProvider,
                          trailing: trailing,
                          onTap: () {
                            doIfLoggedIn(context, () {
                              FavouriteProviderScreen().launch(context);
                            });
                          },
                        ),
                        if (isLoginTypeUser)
                          SettingItemWidget(
                            leading: ic_lock.iconImage(size: SETTING_ICON_SIZE),
                            title: language.changePassword,
                            trailing: trailing,
                            onTap: () {
                              doIfLoggedIn(context, () {
                                ChangePasswordScreen().launch(context);
                              });
                            },
                          ),
                        SettingItemWidget(
                          leading: ic_document.iconImage(size: SETTING_ICON_SIZE),
                          title: language.blogs,
                          trailing: trailing,
                          onTap: () {
                            BlogListScreen().launch(context);
                          },
                        ),
                        SettingItemWidget(
                          leading: ic_star.iconImage(size: SETTING_ICON_SIZE),
                          title: language.rateUs,
                          trailing: trailing,
                          onTap: () async {
                            if (isAndroid) {
                              if (getStringAsync(PLAY_STORE_URL).isNotEmpty) {
                                commonLaunchUrl(getStringAsync(PLAY_STORE_URL), launchMode: LaunchMode.externalApplication);
                              } else {
                                commonLaunchUrl('${getSocialMediaLink(LinkProvider.PLAY_STORE)}$currentPackageName', launchMode: LaunchMode.externalApplication);
                              }
                            } else if (isIOS) {
                              if (getStringAsync(APPSTORE_URL).isNotEmpty) {
                                commonLaunchUrl(getStringAsync(APPSTORE_URL), launchMode: LaunchMode.externalApplication);
                              } else {
                                commonLaunchUrl(IOS_LINK_FOR_USER, launchMode: LaunchMode.externalApplication);
                              }
                            }
                          },
                        ),
                        SettingItemWidget(
                          leading: ic_star.iconImage(size: SETTING_ICON_SIZE),
                          title: language.myReviews,
                          trailing: trailing,
                          onTap: () async {
                            doIfLoggedIn(context, () {
                              CustomerRatingScreen().launch(context);
                            });
                          },
                        ),
                      ],
                    ),
                    SettingSection(
                      title: Text(language.lblAboutApp.toUpperCase(), style: boldTextStyle(color: primaryColor)),
                      headingDecoration: BoxDecoration(color: context.primaryColor.withOpacity(0.1)),
                      divider: Offstage(),
                      items: [
                        8.height,
                        SettingItemWidget(
                          leading: ic_shield_done.iconImage(size: SETTING_ICON_SIZE),
                          title: language.privacyPolicy,
                          onTap: () {
                            checkIfLink(context, appStore.privacyPolicy.validate(), title: language.privacyPolicy);
                          },
                        ),
                        SettingItemWidget(
                          leading: ic_document.iconImage(size: SETTING_ICON_SIZE),
                          title: language.termsCondition,
                          onTap: () {
                            checkIfLink(context, appStore.termConditions.validate(), title: language.termsCondition);
                          },
                        ),
                        SettingItemWidget(
                          leading: ic_helpAndSupport.iconImage(size: SETTING_ICON_SIZE),
                          title: language.helpSupport,
                          onTap: () {
                            checkIfLink(context, appStore.inquiryEmail.validate(), title: language.helpSupport);
                          },
                        ),
                        SettingItemWidget(
                          leading: ic_calling.iconImage(size: SETTING_ICON_SIZE),
                          title: language.lblHelplineNumber,
                          onTap: () {
                            launchCall(appStore.helplineNumber.validate());
                          },
                        ),
                        SettingItemWidget(
                          leading: ic_buy.iconImage(size: SETTING_ICON_SIZE),
                          title: language.lblPurchaseCode,
                          onTap: () {
                            launchUrlCustomTab(PURCHASE_URL);
                          },
                        ).visible(isIqonicProduct),
                        SettingItemWidget(
                          leading: Icon(MaterialCommunityIcons.logout, color: context.iconColor, size: SETTING_ICON_SIZE),
                          title: language.signIn,
                          onTap: () {
                            SignInScreen().launch(context);
                          },
                        ).visible(!appStore.isLoggedIn),
                      ],
                    ),
                    SettingSection(
                      title: Text(language.lblDangerZone.toUpperCase(), style: boldTextStyle(color: redColor)),
                      headingDecoration: BoxDecoration(color: redColor.withOpacity(0.08)),
                      divider: Offstage(),
                      items: [
                        8.height,
                        SettingItemWidget(
                          leading: ic_delete_account.iconImage(size: SETTING_ICON_SIZE),
                          paddingBeforeTrailing: 4,
                          title: language.lblDeleteAccount,
                          onTap: () {
                            showConfirmDialogCustom(
                              context,
                              negativeText: language.lblCancel,
                              positiveText: language.lblDelete,
                              onAccept: (_) {
                                ifNotTester(() {
                                  appStore.setLoading(true);

                                  deleteAccountCompletely().then((value) async {

                                    appStore.setLoading(false);
                                    await userService.deleteUser();
                                    await clearPreferences();

                                    toast(value.message);

                                    push(DashboardScreen(), isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
                                  }).catchError((e) {
                                    appStore.setLoading(false);
                                    toast(e.toString());
                                  });
                                });
                              },
                              dialogType: DialogType.DELETE,
                              title: language.lblDeleteAccountConformation,
                            );
                          },
                        ).paddingOnly(left: 4),
                        64.height,
                        TextButton(
                          child: Text(language.logout, style: boldTextStyle(color: primaryColor, size: 18)),
                          onPressed: () {
                            logout(context);
                          },
                        ).center(),
                      ],
                    ).visible(appStore.isLoggedIn),
                    30.height.visible(!appStore.isLoggedIn),
                    SnapHelperWidget<PackageInfoData>(
                      future: getPackageInfo(),
                      onSuccess: (data) {
                        return TextButton(
                          child: VersionInfoWidget(prefixText: 'v', textStyle: secondaryTextStyle(size: 14)),
                          onPressed: () {
                            showAboutDialog(
                              context: context,
                              applicationName: APP_NAME,
                              applicationVersion: data.versionName,
                              applicationIcon: Image.asset(appLogo, height: 50),
                            );
                          },
                        ).center();
                      },
                    ),
                  ],
                ),
              ),
              Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading))
            ],
          );
        },
      ),
    );
  }
}
