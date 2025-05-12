import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shoppingmegamart/services/extra_functions.dart';

import '../../../size.dart';

class SearchTextField extends StatelessWidget {
  final String hintText, label;
  final TextEditingController controller;

  const SearchTextField(
      {super.key,
      required this.hintText,
      required this.controller,
      required this.label});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8, top: 5),
      child: SizedBox(
        height: 65,
        child: TextFormField(
          controller: controller,
          enabled: true,
          style: GoogleFonts.openSans(
            fontSize: w * .04,
          ),
          maxLines: 1,
          scrollPadding: EdgeInsets.zero,
          cursorColor: primaryColor,
          maxLengthEnforcement:
              MaxLengthEnforcement.truncateAfterCompositionEnds,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.black.withOpacity(.8)),
            // suffixIcon: InkWell(
            //   splashColor: primaryColor.withOpacity(.3),
            //   onTap: () {
            //     if (_searchController.text.length > 3) {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => ProductListScreen(
            //             titleValue: _searchController.text,
            //             database: widget.database,
            //             dataList: const [],
            //             isBrands: false,
            //             searchProduct: true,
            //             isCategory: false, title: 'Looking for: ${_searchController.text}',
            //           ),
            //         ),
            //       );
            //     }
            //   },
            //   child: Icon(
            //     Icons.search,
            //     color: primaryColor,
            //     size: 30,
            //   ),
            // ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10.0,
            ),
            suffixIconColor: primaryColor,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
          ),

          // decoration: InputDecoration(
          //   // enableInteractiveSelection: false,
          //   floatingLabelBehavior:
          //   FloatingLabelBehavior.always,
          //   // hintText: label,
          //   labelText:label,
          //   enabledBorder: OutlineInputBorder(
          //     borderRadius: BorderRadius.circular(
          //       10,
          //     ),
          //   ),
          //   border: OutlineInputBorder(
          //     borderRadius: BorderRadius.circular(
          //       15,
          //     ),
          //   ),
          // ),
        ),
      ),
    );
  }
}
