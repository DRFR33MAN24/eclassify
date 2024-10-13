
import 'package:eClassify/utils/Extensions/extensions.dart';
import 'package:flutter/material.dart';

import '../../../../utils/ui_utils.dart';

class CategoryHomeCard extends StatelessWidget {
  final String title;
  final String url;
  final VoidCallback onTap;
  const CategoryHomeCard({
    super.key,
    required this.title,
    required this.url,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String extension = url.split(".").last.toLowerCase();
    bool isFullImage = false;


    if (extension == "png" || extension == "svg") {
      isFullImage = false;
    } else {
      isFullImage = true;
    }
    return SizedBox(
      width: 70,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
        
          child: Container(
            child: Column(
              children: [
                if (isFullImage) ...[
                  ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                  
                    child: Container(
                      height: 70,
                      width: double.infinity,
                      color: context.color.secondaryColor,
                      child: UiUtils.imageType(url, fit: BoxFit.cover),
                    ),
                  ),
                ] else ...[
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
                          child: UiUtils.imageType(url, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                ],
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(title)
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
      ),
    );
  }
}
