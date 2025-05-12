// To parse this JSON data, do
//
//     final vendorPriceAnalyisModel = vendorPriceAnalyisModelFromJson(jsonString);

import 'dart:convert';

VendorPriceAnalyisModel vendorPriceAnalyisModelFromJson(String str) => VendorPriceAnalyisModel.fromJson(json.decode(str));

String vendorPriceAnalyisModelToJson(VendorPriceAnalyisModel data) => json.encode(data.toJson());

class VendorPriceAnalyisModel {
  final String highestBy15;
  final int idHighestBy15;
  final String highestBy5;
  final int idHighestBy5;
  final String highestBy515;
  final int idHighestBy515;
  final String lowestBy15;
  final int idLowestBy15;
  final String lowestBy5;
  final int idLowestBy5;
  final String lowestBy515;
  final int idLowestBy515;

  VendorPriceAnalyisModel({
    required this.highestBy15,
    required this.idHighestBy15,
    required this.highestBy5,
    required this.idHighestBy5,
    required this.highestBy515,
    required this.idHighestBy515,
    required this.lowestBy15,
    required this.idLowestBy15,
    required this.lowestBy5,
    required this.idLowestBy5,
    required this.lowestBy515,
    required this.idLowestBy515,
  });

  factory VendorPriceAnalyisModel.fromJson(Map<String, dynamic> json) => VendorPriceAnalyisModel(
    highestBy15: json["highest_by_15%"],
    idHighestBy15: json["id_highest_by_15%"],
    highestBy5: json["highest_by_5%"],
    idHighestBy5: json["id_highest_by_5%"],
    highestBy515: json["highest_by_5% - 15%"],
    idHighestBy515: json["id_highest_by_5% - 15%"],
    lowestBy15: json["lowest_by_15%"],
    idLowestBy15: json["id_lowest_by_15%"],
    lowestBy5: json["lowest_by_5%"],
    idLowestBy5: json["id_lowest_by_5%"],
    lowestBy515: json["lowest_by_5% - 15%"],
    idLowestBy515: json["id_lowest_by_5% - 15%"],
  );

  Map<String, dynamic> toJson() => {
    "highest_by_15%": highestBy15,
    "id_highest_by_15%": idHighestBy15,
    "highest_by_5%": highestBy5,
    "id_highest_by_5%": idHighestBy5,
    "highest_by_5% - 15%": highestBy515,
    "id_highest_by_5% - 15%": idHighestBy515,
    "lowest_by_15%": lowestBy15,
    "id_lowest_by_15%": idLowestBy15,
    "lowest_by_5%": lowestBy5,
    "id_lowest_by_5%": idLowestBy5,
    "lowest_by_5% - 15%": lowestBy515,
    "id_lowest_by_5% - 15%": idLowestBy515,
  };
}
