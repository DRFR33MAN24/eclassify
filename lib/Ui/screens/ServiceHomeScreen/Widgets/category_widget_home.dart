import 'package:eClassify/Ui/screens/ItemHomeScreen/home_screen.dart';
import 'package:eClassify/utils/AppIcon.dart';
import 'package:eClassify/utils/Extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';

import '../../../../exports/main_export.dart';
import '../../widgets/Errors/no_data_found.dart';
import '../../main_activity.dart';
import 'category_home_card.dart';

class CategoryWidgetHome extends StatelessWidget {
  const CategoryWidgetHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchServiceCategoryCubit, FetchServiceCategoryState>(
      builder: (context, state) {

        if (state is FetchServiceCategorySuccess) {
          if (state.categories.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                width: context.screenWidth,
                 height: 103,
             




                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: sidePadding,
                  ),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    if (index == state.categories.length) {
                      return moreCategory(context);
                    } else {
                      return CategoryHomeCard(
                        title: state.categories[index].name!,
                        url: state.categories[index].url!,
                        onTap: () {

                          if (state.categories[index].children!.isNotEmpty) {
                            Navigator.pushNamed(
                                context, Routes.subCategoryScreen,
                                arguments: {
                                  "categoryList":
                                      state.categories[index].children,
                                  "catName": state.categories[index].name,
                                  "catId": state.categories[index].id,
                                  "categoryIds":[state.categories[index].id.toString()]
                                });
                          } else {
                            Navigator.pushNamed(context, Routes.itemsList,
                                arguments: {
                                  'catID':
                                      state.categories[index].id.toString(),
                                  'catName': state.categories[index].name,
                                  "categoryIds":[state.categories[index].id.toString()]
                                });
                          }
                        },
                      );
                    }
                  },
                  itemCount: state.categories.length + 1,
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      width: 12,
                    );
                  },
                )));
          } else {
            return Padding(
              padding: const EdgeInsets.all(50.0),
              child: NoDataFound(
                onTap: () {},
              ),
            );
          }
        }
        return Container();
      },
    );
  }

  Widget moreCategory(BuildContext context) {
    return SizedBox(
      width: 70,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, Routes.services,
              arguments: {"from": Routes.home}).then(
            (dynamic value) {
              if (value != null) {
                selectedCategory = value;
                //setState(() {});
              }
            },
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              Container(
                clipBehavior: Clip.antiAlias,
                height: 70,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                
                 
                  color: context.color.secondaryColor,
                ),
                child: Center(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
               
                    child: SizedBox(
                      // color: Colors.blue,
                      width: 48,
                      height: 48,
                      child: Center(
                        child: RotatedBox(
                            quarterTurns: 1,
                            child: UiUtils.getSvg(AppIcons.more,
                                color: context.color.territoryColor)),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text("more".translate(context))
                    .centerAlign()
                    .setMaxLines(lines: 2)
                    .size(context.font.small)
                    .color(
                      context.color.textDefaultColor,
                    ),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
