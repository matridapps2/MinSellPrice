import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class CustomDropdown2 extends StatefulWidget {
  const CustomDropdown2({
    super.key,
    required this.width,
    required this.selectedValue,
    required this.itemsList,
    required this.onChanged,
  });

  final double width;
  final String? selectedValue;
  final List<String> itemsList;
  final void Function(String?)? onChanged;

  @override
  State<CustomDropdown2> createState() => _CustomDropdown2State();
}

class _CustomDropdown2State extends State<CustomDropdown2> {
  EdgeInsetsGeometry pad = const EdgeInsets.symmetric(horizontal: 10);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        enableFeedback: true,
        value: widget.selectedValue,
        items: widget.itemsList.map((value) => _item(value)).toList(),
        onChanged: widget.onChanged,
        buttonStyleData: _buttonStyle(),
        dropdownStyleData: _dropdownStyle(),
        menuItemStyleData: _menuStyle(),
      ),
    );
  }

  DropdownMenuItem<String> _item(String value) {
    return DropdownMenuItem(
      value: value,
      child: Text(
        value,
        maxLines: 1,
        style: const TextStyle(
          fontSize: 18,
          letterSpacing: 0.5,
          color: Colors.black,
          fontFamily: 'Futura BdCn BT Bold',
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  ButtonStyleData _buttonStyle() {
    return ButtonStyleData(
      height: 45,
      padding: pad,
      width: widget.width,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
      ),
    );
  }

  DropdownStyleData _dropdownStyle() {
    return DropdownStyleData(
      maxHeight: 250,
      width: widget.width,
      scrollbarTheme: const ScrollbarThemeData(
        thickness: WidgetStatePropertyAll(6),
        thumbVisibility: WidgetStatePropertyAll(true),
      ),
    );
  }

  MenuItemStyleData _menuStyle() {
    const color = WidgetStatePropertyAll(Color.fromARGB(255, 220, 220, 220));
    return MenuItemStyleData(height: 45, padding: pad, overlayColor: color);
  }
}
