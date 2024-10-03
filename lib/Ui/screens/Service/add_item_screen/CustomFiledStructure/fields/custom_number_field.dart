import 'package:eClassify/utils/Extensions/extensions.dart';
import 'package:eClassify/utils/responsiveSize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../../utils/ui_utils.dart';
import '../../../../widgets/DynamicField/dynamic_field.dart';
import '../../../../widgets/custom_text_form_field.dart';
import '../custom_field.dart';

class CustomNumberField extends CustomField {
  @override
  String type = "number";
  String initialValue = "";

  @override
  void init() {
    if (parameters['isEdit'] == true) {
      if (parameters['value'] != null) {
        if ((parameters['value'] as List).isNotEmpty) {
          initialValue = parameters['value'][0].toString();
          update(() {});
        }
      }
    }
    super.init();
  }

  @override
  Widget render() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0),
        child: Column(
          children: [
            Row(
              children: [
                if (parameters['image'] != null) ...[
                  Container(
                    width: 48.rw(context),
                    height: 48.rh(context),
                    decoration: BoxDecoration(
                      color: context.color.territoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: FittedBox(
                        fit: BoxFit.none,
                        child: UiUtils.imageType(parameters['image'],
                            width: 24,
                            height: 24,
                            fit: BoxFit.cover,
                            color: context.color.textDefaultColor),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.rw(context),
                  ),
                ],
                Text(parameters['name'])
                    .size(context.font.large)
                    .bold(weight: FontWeight.w500)
                    .color(context.color.textColorDark)
              ],
            ),
            SizedBox(
              height: 14.rh(context),
            ),
            CustomTextFieldDynamic(
              initController: parameters['value'] != null ? true : false,
              value: initialValue,
              validator: CustomTextFieldValidator.minAndMixLen,
              maxLen: parameters['max_length'],
              minLen: parameters['min_length'],
              hintText: "",
              //"addNumerical".translate(context),
              formaters: [
                FilteringTextInputFormatter.allow(
                  RegExp("[0-9]"),
                ),
              ],
              action: TextInputAction.next,
              keyboardType: TextInputType.number,
              required: parameters['required'] == 1 ? true : false,
              id: parameters['id'],
            ),
          ],
        ));
  }
}
