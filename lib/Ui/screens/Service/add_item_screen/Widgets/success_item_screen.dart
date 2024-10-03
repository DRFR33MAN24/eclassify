import 'package:eClassify/utils/Extensions/extensions.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../widgets/AnimatedRoutes/blur_page_route.dart';
import '../../../main_activity.dart';

class SuccessItemScreen extends StatefulWidget {
  final ItemModel model;
  final bool isEdit;

  const SuccessItemScreen(
      {super.key, required this.model, required this.isEdit});

  static Route route(RouteSettings settings) {
    Map? arguments = settings.arguments as Map?;
    return BlurredRouter(
      builder: (context) {
        return SuccessItemScreen(
          model: arguments!['model'],
          isEdit: arguments['isEdit'],
        );
      },
    );
  }

  @override
  _SuccessItemScreenState createState() => _SuccessItemScreenState();
}

class _SuccessItemScreenState extends State<SuccessItemScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isSuccessShown = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool isBack = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _isLoading = false;
      _isSuccessShown = true;
    }

    _slideController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1), // Adjust duration as needed
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.isEdit ? 0 : 1.5), // Off-screen initially
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    // Simulate loading time
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
      // Show success animation after loading animation completes
      Future.delayed(const Duration(seconds: 0), () {
        if (mounted)
          setState(() {
            _isSuccessShown = true;
            Future.delayed(const Duration(seconds: 1), () {
              _slideController.forward();
            }); // Start slide animation
          });
      });
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _handleBackButtonPressed() {
    if (_isSuccessShown && _slideController.isAnimating) {
      setState(() {
        isBack = false;
      });
      // Don't allow popping while the animation is playing
      return;
    } else {
      // Navigate back to the home screen
      _navigateBackToHome();
      return;
    }
  }

  void _navigateToAdDetailsScreen() {
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushNamed(
      context,
      Routes.serviceDetailsScreen,
      arguments: {
        'model': widget.model,
      },
    );
  }

  void _navigateBackToHome() {
    if (mounted)
      Future.delayed(
        Duration(milliseconds: 500),
        () {
          if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
          MainActivity.globalKey.currentState?.onItemTapped(0);
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isBack,
      onPopInvoked: (didPop) async {
        // Handle back button press
        _handleBackButtonPressed();
      },
      child: Scaffold(
        body: Center(
          child: _isLoading
              ? Lottie.asset(
                  "assets/lottie/${Constant.loadingSuccessLottieFile}") // Replace with your loading animation
              : _isSuccessShown
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                            "assets/lottie/${Constant.successItemLottieFile}",
                            repeat: false),
                        SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              SizedBox(height: 50),
                              if (!widget.isEdit)
                                Text(
                                  'congratulations'.translate(context),
                                )
                                    .size(context.font.extraLarge)
                                    .color(context.color.territoryColor)
                                    .bold(weight: FontWeight.w600),
                              SizedBox(height: 18),
                              Text(widget.isEdit
                                      ? 'updatedSuccess'.translate(context)
                                      : 'submittedSuccess'.translate(context))
                                  .centerAlign()
                                  .size(context.font.larger)
                                  .color(context.color.textDefaultColor),
                              SizedBox(height: 60),
                              InkWell(
                                onTap: () {
                                  _navigateToAdDetailsScreen();
                                  //pageCntrlr.jumpToPage(3);
                                  /*  Navigator.pushReplacementNamed(
                                      context,
                                      Routes.main,
                                      arguments: {"from": "successItem"},
                                    ).then((_) {
                                      context
                                          .read<NavigationCubit>()
                                          .navigateToMyItems();
                                    });*/
                                  /*  Navigator.pushNamed(
                                      context,
                                      Routes.myItemScreen,
                                    );*/
                                },
                                child: Container(
                                  height: 48,
                                  alignment: AlignmentDirectional.center,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 65, vertical: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: context.color.territoryColor),
                                      color: context.color.secondaryColor),
                                  child: Text("previewAd".translate(context))
                                      .centerAlign()
                                      .size(context.font.larger)
                                      .color(context.color.territoryColor),
                                ),
                              ),
                              SizedBox(height: 15),
                              InkWell(
                                onTap: () {
                                  _navigateBackToHome();
                                },
                                child: Text('backToHome'.translate(context))
                                    .underline()
                                    .centerAlign()
                                    .size(context.font.larger)
                                    .color(context.color.textDefaultColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : SizedBox(), // Placeholder
        ),
      ),
    );
  }
}
