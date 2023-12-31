import 'package:bill_split_calculator/Constants/constants.dart';
import 'package:flutter/material.dart';

///Reusable with title and form
class CustomTextField extends StatelessWidget {
  ///var
  final String? textTitle;
  final String? hintText;
  final IconData? prefixIcon;

  final TextEditingController? textEditingController;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool isInstructionNeeded;

  ///consts
  const CustomTextField({
    super.key,
    this.textTitle,
    this.hintText,
    this.prefixIcon,
    this.textEditingController,
    this.validator,
    this.onChanged,
    this.isInstructionNeeded = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          ///Text
          Align(
            alignment: Alignment.centerLeft,
            child: isInstructionNeeded == false
                ? Text(
                    textTitle ?? "textTitle",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.5,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        textTitle ?? "textTitle",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          AppUtilities.showDialogMessage(
                              context,
                              "How to Use this Field?",
                              AppUtilities.instruction);
                        },
                        icon: Icon(Icons.info_outline),
                      ),
                    ],
                  ),
          ),

          ///Sized Box
          SizedBox(height: 10),

          ///FormField
          Container(
            height: MediaQuery.of(context).size.height * 0.090,
            child: Card(
              child: Center(
                child: TextFormField(
                  controller: textEditingController,
                  validator: validator,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(16.0),
                    border: InputBorder.none,
                    prefixIcon: Icon(prefixIcon ?? Icons.person_outline),
                    hintText: hintText ?? "hintText",
                  ),
                  onChanged: onChanged,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
