import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shoppingmegamart/bloc/vendor_details_bloc/vendor_details_bloc.dart';
import 'package:shoppingmegamart/services/extra_functions.dart';
class DatePickerFormField extends StatefulWidget {
  const DatePickerFormField({
    super.key,
    required this.vendorId
  });

  final int vendorId;

  @override
  _DatePickerFormFieldState createState() => _DatePickerFormFieldState();
}

class _DatePickerFormFieldState extends State<DatePickerFormField> {
  DateTime selectedDate = DateTime.now().subtract(const Duration(days: 1));



  List<DateTime> returnDisableDate() {
    List<DateTime> futureDates = [];

    DateTime today = DateTime.now();
    DateTime endDate =
    today.add(const Duration(days: 30)); // Adjust the end date as needed

    while (today.isBefore(endDate)) {
      today = today.add(const Duration(days: 1));
      futureDates.add(today);
    }
    return futureDates;
  }

  Future<void> _selectDate(BuildContext context) async {
    List<DateTime> futureDates = [];

    DateTime today = DateTime.now();
    DateTime endDate =
    today.add(const Duration(days: 365)); // Adjust the end date as needed

    while (today.isBefore(endDate)) {
      today = today.add(const Duration(days: 1));
      futureDates.add(today);
    }
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime.now().subtract(const Duration(days: 1)),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
      if (mounted) {
        context.read<VendorDetailsBloc>().add(
          VendorDetailsFetchingEvent(
            vendorId: widget.vendorId.toString(),
            date: dateFormat
                .format(
              selectedDate,
            )
                .replaceAll('/', '-'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // const SizedBox(
          //   height: 10,
          // ),
          // AutoSizeText('Select your Vendor',
          //     style: GoogleFonts.montserrat(
          //         color: Colors.black,
          //         fontSize: w * .05,
          //         fontWeight: FontWeight.bold)),
          // const SizedBox(
          //   height: 10,
          // ),
          // SizedBox(
          //   width: w,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     children: [
          //       Padding(
          //         padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //         child: GestureDetector(
          //           onTap: () {
          //             widget.changingAFSupply(selectedDate);
          //             setState(() {
          //               activeIndex = 0;
          //               vendorId = AppInfo.kVendorId;
          //             });
          //             context.read<VendorDetailsBloc>().add(
          //                   VendorDetailsFetchingEvent(
          //                     vendorId: vendorId.toString(),
          //                     date: dateFormat
          //                         .format(
          //                           selectedDate,
          //                         )
          //                         .replaceAll('/', '-'),
          //                   ),
          //                 );
          //           },
          //           child: Card(
          //             shape: Border.all(
          //                 color: activeIndex == 0
          //                     ? Colors.lightBlue
          //                     : Colors.white,
          //                 width: 5),
          //             // color: ,
          //             child: Padding(
          //               padding: const EdgeInsets.all(8.0),
          //               child: Image.asset(
          //                 Assets.assetsAfSupply,
          //                 width: w * 0.3,
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //       Padding(
          //         padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //         child: GestureDetector(
          //           onTap: () {
          //             widget.changingHomePerfect(selectedDate);
          //             setState(() {
          //               activeIndex = 1;
          //               vendorId = 10024;
          //             });
          //             context.read<VendorDetailsBloc>().add(
          //                   VendorDetailsFetchingEvent(
          //                     vendorId: vendorId.toString(),
          //                     date: dateFormat
          //                         .format(
          //                           selectedDate,
          //                         )
          //                         .replaceAll('/', '-'),
          //                   ),
          //                 );
          //           },
          //           child: Card(
          //             shape: Border.all(
          //                 color: activeIndex == 1
          //                     ? Colors.lightBlue
          //                     : Colors.white,
          //                 width: 5),
          //             child: Padding(
          //               padding: const EdgeInsets.all(8.0),
          //               child: Image.asset(
          //                 Assets.assetsHomePerfect,
          //                 width: w * .3,
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // const SizedBox(
          //   height: 10,
          // ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              onTap: () {
                _selectDate(context);
              },
              readOnly: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                floatingLabelStyle:
                GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                labelText: 'Date',
                hintText: dateFormat.format(selectedDate),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              controller: TextEditingController(
                text: dateFormat.format(selectedDate),
              ),
            ),
          ),
        ],
      ),
    );
  }
}