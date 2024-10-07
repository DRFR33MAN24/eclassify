import 'package:eClassify/Ui/screens/Item/my_item_tab_screen.dart' as item;
import 'package:eClassify/Ui/screens/Service/my_item_tab_screen.dart' as service;
import 'package:eClassify/data/cubits/item/fetch_my_item_cubit.dart' as item;
import 'package:eClassify/data/cubits/service/fetch_my_item_cubit.dart' as service;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/Extensions/extensions.dart';
import '../../../utils/ui_utils.dart';
import '../widgets/AnimatedRoutes/blur_page_route.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => MyItemState();

  static Route route(RouteSettings routeSettings) {
    return BlurredRouter(
      builder: (_) => const ItemsScreen(),
    );
  }
}

class MyItemState extends State<ItemsScreen> with TickerProviderStateMixin {
  int offset = 0, total = 0;
  int selectTab = 0;
   int selectType = 0;
  final PageController _pageController = PageController();
  List<Map> sections = [];
  List<Map> types = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

      types = [
      {
        "title": "item".translate(context),
        "status": "item",
      },
      {
        "title": "service".translate(context),
        "status": "service",
      },
    ];
    sections = [
      {
        "title": "all".translate(context),
        "status": "",
      },
      {
        "title": "live".translate(context),
        "status": "approved",
      },
      {
        "title": "deactivate".translate(context),
        "status": "inactive",
      },
      {
        "title": "underReview".translate(context),
        "status": "review",
      },
      {
        "title": "soldOut".translate(context),
        "status": "sold out",
      },
      {
        "title": "rejected".translate(context),
        "status": "rejected",
      },
    ];
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(
          context: context, statusBarColor: context.color.secondaryColor),
      child: Scaffold(
        backgroundColor: context.color.primaryColor,
        appBar: UiUtils.buildAppBar(
          context,
          title: "myAds".translate(context),
          // bottomHeight: 49,
          bottomHeight: 100,

          bottom: [
              SizedBox(
              width: context.screenWidth,
              height: 45,
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsetsDirectional.fromSTEB(18, 5, 18, 2),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  Map type = types[index];
                  return customTab(
                    context,
                    isSelected: (selectType == index),
                    onTap: () {
                      selectType = index;
                      //itemScreenCurrentPage = index;
                      setState(() {});
                    
                    },
                    name: type['title'],
                    onDoubleTap: () {},
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    width: 8,
                  );
                },
                itemCount: types.length,
              ),
            ),
            SizedBox(
              width: context.screenWidth,
              height: 45,
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsetsDirectional.fromSTEB(18, 5, 18, 2),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  Map section = sections[index];
                  return customTab(
                    context,
                    isSelected: (selectTab == index),
                    onTap: () {
                      selectTab = index;
                      //itemScreenCurrentPage = index;
                      setState(() {});
                      _pageController.jumpToPage(index);
                    },
                    name: section['title'],
                    onDoubleTap: () {},
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    width: 8,
                  );
                },
                itemCount: sections.length,
              ),
            ),
          ],
        ),
        body: ScrollConfiguration(
          behavior: RemoveGlow(),
          child: PageView(
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (value) {
              //itemScreenCurrentPage = value;
              selectTab = value;
              setState(() {});
            },
            controller: _pageController,
            children: List.generate(sections.length, (index) {
              Map section = sections[index];

        if(selectType==0){
              return BlocProvider(
                create: (context) => item.FetchMyItemsCubit(),
                child: Builder(builder: (context) {
              
                    return item.MyItemTab(
                    //getActiveItems: section['active'],
                    getItemsWithStatus: section['status'],
                  );
               
                }),
                );
            }
            else {  
              return BlocProvider(
                create: (context) => service.FetchMyItemsCubit(),
                child: Builder(builder: (context) {
              
                    return service.MyItemTab(
                    //getActiveItems: section['active'],
                    getItemsWithStatus: section['status'],
                  );
            }),
              );
            }
            }),
          ),
        ),
      ),
    );
  }

  Widget customTab(
    BuildContext context, {
    required bool isSelected,
    required String name,
    required Function() onTap,
    required Function() onDoubleTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 110,
        ),
        height: 40,
        decoration: BoxDecoration(
            color: (isSelected
                ? (context.color.territoryColor)
                : Colors.transparent),
            border: Border.all(
              color: isSelected
                  ? context.color.territoryColor
                  : context.color.textLightColor,
            ),
            borderRadius: BorderRadius.circular(11)),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(name).size(context.font.large).color(isSelected
                ? context.color.buttonColor
                : context.color.textColorDark),
          ),
        ),
      ),
    );
  }
}
