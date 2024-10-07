// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:eClassify/Ui/screens/widgets/maintenance_mode.dart';
import 'package:eClassify/Ui/screens/widgets/AnimatedRoutes/blur_page_route.dart';
import 'package:eClassify/utils/Svg/svg_edit.dart';
import 'package:eClassify/exports/main_export.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/AppIcon.dart';

import '../../data/cubits/item/search_item_cubit.dart';

import '../../data/cubits/subscription/fetch_user_package_limit_cubit.dart';

import '../../data/model/item/item_model.dart';
import '../../data/model/system_settings_model.dart';
import '../../utils/Extensions/extensions.dart';

import '../../utils/errorFilter.dart';

import '../../utils/helper_utils.dart';

import '../../utils/responsiveSize.dart';
import '../../utils/ui_utils.dart';
import 'ItemHomeScreen/search_screen.dart';
import 'Item/my_items_screen.dart';
import 'Userprofile/profile_screen.dart';
import 'chat/chat_list_screen.dart';

import 'ItemHomeScreen/home_screen.dart' as ItemsUI;
import 'ServiceHomeScreen/home_screen.dart' as ServicesUI;
import 'widgets/blurred_dialoge_box.dart';

List<ItemModel> myItemlist = [];
Map<String, dynamic> searchbody = {};
String selectedcategoryId = "0";
String selectedcategoryName = "";
dynamic selectedCategory;

//this will set when i will visit in any category
dynamic currentVisitingCategoryId = "";
dynamic currentVisitingCategory = "";

List<int> navigationStack = [0];

ScrollController homeScreenController = ScrollController();
//ScrollController chatScreenController = ScrollController();
ScrollController profileScreenController = ScrollController();

List<ScrollController> controllerList = [
  homeScreenController,
  //chatScreenController,
  profileScreenController
];

//
class MainActivity extends StatefulWidget {
  final String from;
  static final GlobalKey<MainActivityState> globalKey =
      GlobalKey<MainActivityState>();

  MainActivity({Key? key, required this.from}) : super(key: globalKey);

  @override
  State<MainActivity> createState() => MainActivityState();

  static Route route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return BlurredRouter(
        builder: (_) => MainActivity(from: arguments['from'] as String));
  }
}

class MainActivityState extends State<MainActivity>
    with TickerProviderStateMixin {
  PageController pageCntrlr = PageController(initialPage: 0);
  int currtab = 0;
  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final List _pageHistory = [];

  DateTime? currentBackPressTime;

//This is rive file artboards and setting you can check rive package's documentation at [pub.dev]
  bool svgLoaded = false;
  bool isAddMenuOpen = false;
  int rotateAnimationDurationMs = 2000;

  bool isChecked = false;
  SVGEdit svgEdit = SVGEdit();
  bool isBack = false;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
 bool isReverse = false;
  @override
  void initState() {
    super.initState();

    initAppLinks();

    rootBundle.loadString(AppIcons.plusIcon).then((value) {
      svgEdit.loadSVG(value);
      svgEdit.change("Path_11299-2",
          attribute: "fill",
          value: svgEdit.flutterColorToHexColor(context.color.territoryColor));
      svgLoaded = true;
      setState(() {});
    });

    //GuestChecker.setContext(context);
    //GuestChecker.set(isGuest: HiveUtils.isGuest());

    FetchSystemSettingsCubit settings =
        context.read<FetchSystemSettingsCubit>();
    if (!const bool.fromEnvironment("force-disable-demo-mode",
        defaultValue: false)) {
      Constant.isDemoModeOn =
          settings.getSetting(SystemSetting.demoMode) ?? false;
    }
    var numberWithSuffix = settings.getSetting(SystemSetting.numberWithSuffix);
    Constant.isNumberWithSuffix = numberWithSuffix == "1" ? true : false;

    ///this will check if your profile is complete or not if it is incomplete it will redirect you to the edit profile page
    // completeProfileCheck();

    ///This will check for update
    versionCheck(settings);

    ///This will check if location is set or not , If it is not set it will show popup dialoge so you can set for better result
    /*   if (HiveUtils.isUserAuthenticated()) {
      locationSetCheck();
    }*/

//This will init page controller
    initPageController();
  }

  Future<void> initAppLinks() async {
    _appLinks = AppLinks();


    // Listen for incoming deep links
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {

      if (uri != null) {
        handleDeepLink(uri);
      }
    });
  }

  void handleDeepLink(Uri uri) {
    if (uri.path.contains('/items-details/')) {
      Navigator.push(
        context,
        Routes.onGenerateRouted(RouteSettings(name: uri.toString())),
      );
    } else {
      print('Received deep link: $uri');
      // Handle other deep link paths here if necessary
    }
  }


  void addHistory(int index) {
    List<int> stack = navigationStack;
    // if (stack.length > 5) {
    //   stack.removeAt(0);
    // } else {
    if (stack.last != index) {
      stack.add(index);
      navigationStack = stack;
    }

    setState(() {});
  }

  void initPageController() {
    pageCntrlr
      ..addListener(() {
        _pageHistory.insert(0, pageCntrlr.page);
      });
  }

  void completeProfileCheck() {
    if (HiveUtils.getUserDetails().name == "" ||
        HiveUtils.getUserDetails().email == "") {
      Future.delayed(
        const Duration(milliseconds: 100),
        () {
          Navigator.pushReplacementNamed(context, Routes.completeProfile,
              arguments: {"from": "login"});
        },
      );
    }
  }

  void versionCheck(settings) async {
    var remoteVersion = settings.getSetting(Platform.isIOS
        ? SystemSetting.iosVersion
        : SystemSetting.androidVersion);
    var remote = remoteVersion;

    var forceUpdate = settings.getSetting(SystemSetting.forceUpdate);

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    var current = packageInfo.version;

    int currentVersion = HelperUtils.comparableVersion(packageInfo.version);
    if (remoteVersion == null) {
      return;
    }

    remoteVersion = HelperUtils.comparableVersion(
      remoteVersion,
    );

    if (remoteVersion > currentVersion) {
      Constant.isUpdateAvailable = true;
      Constant.newVersionNumber = settings.getSetting(
        Platform.isIOS
            ? SystemSetting.iosVersion
            : SystemSetting.androidVersion,
      );

      Future.delayed(
        Duration.zero,
        () {
          if (forceUpdate == "1") {
            ///This is force update
            UiUtils.showBlurredDialoge(context,
                dialoge: BlurredDialogBox(
                    onAccept: () async {
                      await launchUrl(
                          Uri.parse(
                            Constant.playstoreURLAndroid,
                          ),
                          mode: LaunchMode.externalApplication);
                    },
                    backAllowedButton: false,
                    svgImagePath: AppIcons.update,
                    isAcceptContainesPush: true,
                    svgImageColor: context.color.territoryColor,
                    showCancleButton: false,
                    title: "updateAvailable".translate(context),
                    acceptTextColor: context.color.buttonColor,
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("$current>$remote"),
                        Text("newVersionAvailableForce".translate(context),
                            textAlign: TextAlign.center),
                      ],
                    )));
          } else {
            UiUtils.showBlurredDialoge(
              context,
              dialoge: BlurredDialogBox(
                onAccept: () async {
                  await launchUrl(Uri.parse(Constant.playstoreURLAndroid),
                      mode: LaunchMode.externalApplication);
                },
                svgImagePath: AppIcons.update,
                svgImageColor: context.color.territoryColor,
                showCancleButton: true,
                title: "updateAvailable".translate(context),
                content: Text(
                  "newVersionAvailable".translate(context),
                ),
              ),
            );
          }
        },
      );
    }
  }

  void locationSetCheck() {
    if (HiveUtils.isShowChooseLocationDialoge() &&
        !HiveUtils.isLocationFilled()) {
      Future.delayed(
        Duration.zero,
        () {
          UiUtils.showBlurredDialoge(
            context,
            dialoge: BlurredDialogBox(
              title: "setLocation".translate(context),
              content: StatefulBuilder(builder: (context, update) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "setLocationforBetter".translate(context),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          fillColor: WidgetStateProperty.resolveWith(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.selected)) {
                                return context.color.territoryColor;
                              } else {
                                return context.color.primaryColor;
                              }
                            },
                            // context.color.primaryColor,
                          ),
                          value: isChecked,
                          onChanged: (value) {
                            isChecked = value ?? false;
                            update(() {});
                          },
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text("dontshowagain".translate(context))
                      ],
                    ),
                  ],
                );
              }),
              isAcceptContainesPush: true,
              onCancel: () {
                if (isChecked == true) {
                  HiveUtils.dontShowChooseLocationDialoge();
                }
              },
              onAccept: () async {
                if (isChecked == true) {
                  HiveUtils.dontShowChooseLocationDialoge();
                }
                Navigator.pop(context);

                Navigator.pushNamed(context, Routes.completeProfile,
                    arguments: {
                      "from": "chooseLocation",
                      "navigateToHome": true
                    });
              },
            ),
          );
        },
      );
    }
  }

  @override
  void didChangeDependencies() {
    ErrorFilter.setContext(context);

    svgEdit.change("Path_11299-2",
        attribute: "fill",
        value: svgEdit.flutterColorToHexColor(context.color.territoryColor));
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    pageCntrlr.dispose();
    _linkSubscription?.cancel();
    super.dispose();
  }

/*  Future<void> checkForMaintenanceMode() async {
    Map<String, String> body = {
      Api.type: Api.maintenanceMode,
    };

    var response = await Api.get(
      url: Api.getSystemSettingsApi,
      queryParameters: body,
    );
    var getdata = json.decode(response);

    if (getdata != null) {
      if (!getdata[Api.error]) {
        Constant.maintenanceMode = getdata['data'].toString();
        if (Constant.maintenanceMode == "1") {
          setState(() {});
        }
      }
    }
  }*/

  late List<Widget> pages = [
    ItemsUI.HomeScreen(from: widget.from,),
    ServicesUI.HomeScreen(from: widget.from),
    const ItemsScreen(),
    const ProfileScreen(),
    ChatListScreen(),
  ];

      ///Animation for sell and rent button
  late final AnimationController _forSellAnimationController =
      AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 400),
          reverseDuration: const Duration(milliseconds: 400));
  late final AnimationController _forRentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 300));

  ///END: Animation for sell and rent button
  late final Animation<double> _sellTween = Tween<double>(begin: -50, end: 80)
      .animate(CurvedAnimation(
          parent: _forSellAnimationController, curve: Curves.easeIn));
  late final Animation<double> _rentTween = Tween<double>(begin: -50, end: 30)
      .animate(
          CurvedAnimation(parent: _forRentController, curve: Curves.easeIn));

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(
          context: context, statusBarColor: context.color.primaryColor),
      child: PopScope(
        canPop: isBack,
        onPopInvoked: (didPop) {
          if (currtab != 0) {
            pageCntrlr.animateToPage(0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut);
            setState(() {
              currtab = 0;
              isBack = false;
            });
            return;
          } else {
            DateTime now = DateTime.now();
            if (currentBackPressTime == null ||
                now.difference(currentBackPressTime!) >
                    const Duration(seconds: 2)) {
              currentBackPressTime = now;

              HelperUtils.showSnackBarMessage(
                  context, "pressAgainToExit".translate(context));

              setState(() {
                isBack = false;
              });
              return;
            }
            setState(() {
              isBack = true;
            });
            return;
          }
        },
        child: Scaffold(
          backgroundColor: context.color.primaryColor,
                floatingActionButton:FloatingActionButton(onPressed: null,child: 
          Material(
        type: MaterialType.transparency,
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () {
                UiUtils.checkUser(
          onNotGuest: () {
 
pageCntrlr.animateToPage(5,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut);
          },
          context: context);
            
          }            ,
          child:  UiUtils.getSvg(
                  AppIcons.chatNav,
                ),
        ),
      ),backgroundColor: context.color.secondaryColor,),
          bottomNavigationBar:
              Constant.maintenanceMode == "1" ? null : bottomBar(),
          body: Stack(
            children: <Widget>[
              PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: pageCntrlr,
                //onPageChanged: onItemSwipe,
                children: pages,
              ),
              if (Constant.maintenanceMode == "1") MaintenanceMode(),
                 SizedBox(
                width: double.infinity,
                height: context.screenHeight,
                child: Stack(
                  children: [
                    AnimatedBuilder(
                        animation: _forRentController,
                        builder: (context, c) {
                          return Positioned(
                            bottom: _rentTween.value,
                            left: (context.screenWidth / 2) - (181 / 2),
                            child:      BlocListener<FetchUserPackageLimitCubit,
                      FetchUserPackageLimitState>(
                  listener: (context, state) {
                    if (state is FetchUserPackageLimitFailure) {
                      UiUtils.noPackageAvailableDialog(context);
                    }
                    if (state is FetchUserPackageLimitInSuccess) {
                      UiUtils.checkUser(
                          onNotGuest: () {
                            Navigator.pushNamed(
                                context, Routes.selectCategoryScreen,
                                arguments: <String, dynamic>{});
                          },
                          context: context);
                    }
                  },
                  child: 
                             GestureDetector(
                              onTap: () {
                                                        context
                            .read<FetchUserPackageLimitCubit>()
                            .fetchUserPackageLimit(packageType: "item_listing");
                             
                              },
                              child: Container(
                                  width: 181,
                                  height: 44,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: context.color.borderColor,
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: context.color.primaryColor
                                              .withOpacity(0.4),
                                          offset: const Offset(0, 3),
                                          blurRadius: 10,
                                          spreadRadius: 0,
                                        )
                                      ],
                                      color: context.color.territoryColor,
                                      borderRadius: BorderRadius.circular(22)),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      UiUtils.getSvg(AppIcons.adsNav,color: context.color.onTertiary,height: 24,width: 24),
                                      SizedBox(
                                        width: 7.rw(context),
                                      ),
                                      Text(UiUtils.getTranslatedLabel(
                                              context, "AD"))
                                          .color(context.color.buttonColor),
                                    ],
                                  )),
                            )),
                          );
                        }),
                    AnimatedBuilder(
                        animation: _forSellAnimationController,
                        builder: (context, c) {
                          return Positioned(
                            bottom: _sellTween.value,
                            left: (context.screenWidth / 2) - 128 / 2,
                            child: GestureDetector(
                              onTap: () {
                                                UiUtils.checkUser(
                          onNotGuest: () {
                            Navigator.pushNamed(
                                context, Routes.selectServiceCategoryScreen,
                                arguments: <String, dynamic>{});
                          },
                          context: context);
                              },
                              child: Container(
                                width: 128,
                                height: 44,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: context.color.borderColor,
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: context.color.territoryColor
                                            .withOpacity(0.4),
                                        offset: const Offset(0, 3),
                                        blurRadius: 10,
                                        spreadRadius: 0,
                                      )
                                    ],
                                    color: context.color.territoryColor,
                                    borderRadius: BorderRadius.circular(22)),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    UiUtils.getSvg(AppIcons.serviceNav,color: context.color.onTertiary,width: 24,height: 24),
                                    SizedBox(
                                      width: 7.rw(context),
                                    ),
                                    Text(UiUtils.getTranslatedLabel(
                                            context, "Service"))
                                        .color(context.color.buttonColor),
                                  ],
                                ),
                              ),
                            ),
                          );})]))
            ],
          ),
        ),
      ),
    );
  }

  void onItemTapped(int index) {
    addHistory(index);

    if (index == currtab) {
      /* var xIndex = index;

      if (xIndex == 3) {
        xIndex = 2;
      } else if (xIndex == 4) {
        xIndex = 3;
      }*/
      if (controllerList[index].hasClients) {
        controllerList[index].animateTo(0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.bounceOut);
      }
    }
    FocusManager.instance.primaryFocus?.unfocus();

      _forSellAnimationController.reverse();
    _forRentController.reverse();

    if (index != 1) {
      context.read<SearchItemCubit>().clearSearch();

      if (SearchScreenState.searchController.hasListeners) {
        SearchScreenState.searchController.text = "";
      }
    }
    searchbody = {};
    if (index == 2) {
      UiUtils.checkUser(
          onNotGuest: () {
            currtab = index;
            pageCntrlr.jumpToPage(currtab);
            setState(
              () {},
            );
          },
          context: context);
    } else {
      currtab = index;
      pageCntrlr.jumpToPage(currtab);

      setState(() {});
    }
  }

/*  void onItemTapped(int index) {
    addHistory(index);

    if (index == currtab) {
      var xIndex = index;

      if (xIndex == 3) {
        xIndex = 2;
      } else if (xIndex == 4) {
        xIndex = 3;
      }
      if (controllerList[xIndex].hasClients) {
        controllerList[xIndex].animateTo(0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.bounceOut);
      }
    }
    FocusManager.instance.primaryFocus?.unfocus();
    _forSellAnimationController.reverse();
    _forRentController.reverse();

    if (index != 1) {
      context.read<SearchItemCubit>().clearSearch();

      if (SearchScreenState.searchController.hasListeners) {
        SearchScreenState.searchController.text = "";
      }
    }
    searchbody = {};
    if (index == 1 || index == 3) {
      // GuestChecker.check(onNotGuest: () {
      currtab = index;
      pageCntrlr.jumpToPage(currtab);
      setState(
        () {},
      );
      // });
    } else {
      currtab = index;
      pageCntrlr.jumpToPage(currtab);

      setState(() {});
    }
  }*/

  BottomAppBar bottomBar() {
    return BottomAppBar(
      color: context.color.secondaryColor,
      shape: const CircularNotchedRectangle(),
      child: Container(
        color: context.color.secondaryColor,
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              buildBottomNavigationbarItem(0, AppIcons.adsNav,
                  AppIcons.adsNavActive, "adsTab".translate(context)),
              // buildBottomNavigationbarItem(1, AppIcons.chatNav,
              //     AppIcons.chatNavActive, "chat".translate(context)),
                                              buildBottomNavigationbarItem(1, AppIcons.serviceNav,
                  AppIcons.serviceNavActive, "servicesTab".translate(context)),
              Transform(
                transform: Matrix4.identity()..translate(0.toDouble(), -20),
                child: GestureDetector(
                  onTap: () async {
                                        if (isReverse == false) {
                  isReverse = true;
                              
                  _forRentController.forward();
                  _forSellAnimationController.forward();
                } else {
                               
                  isReverse = false;
                  _forRentController.reverse();
                  _forSellAnimationController.reverse();
                }
              
              
                  },
                  child: SizedBox(
                    width: 53.rw(context),
                    height: 58,
                    child: svgLoaded == false
                        ? Container()
                        : SvgPicture.string(
                            svgEdit.toSVGString() ?? "",
                          ),
                  ),
                ),
              ),
              buildBottomNavigationbarItem(2, AppIcons.myAdsNav,
                  AppIcons.myAdsNavActive, "myContent".translate(context)),

              buildBottomNavigationbarItem(3, AppIcons.profileNav,
                  AppIcons.profileNavActive, "profileTab".translate(context))
            ]),
      ),
    );
  }

  Widget buildBottomNavigationbarItem(
    int index,
    String svgImage,
    String activeSvg,
    String title,
  ) {
    return Expanded(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () => onItemTapped(index),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (currtab == index) ...{
                UiUtils.getSvg(activeSvg,height: 20,width: 20),
              } else ...{
                UiUtils.getSvg(svgImage,
                    color: context.color.textLightColor.darken(30),height: 20,width: 20),
              },
              Text(
                title,
                textAlign: TextAlign.center,
              ).color(currtab == index
                  ? context.color.textDefaultColor
                  : context.color.textLightColor.darken(30)),
            ],
          ),
        ),
      ),
    );
  }
}
