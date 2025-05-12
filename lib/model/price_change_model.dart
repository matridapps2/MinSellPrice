// To parse this JSON data, do
//
//     final priceChangeModel = priceChangeModelFromJson(jsonString);

import 'dart:convert';

PriceChangeModel priceChangeModelFromJson(String str) => PriceChangeModel.fromJson(json.decode(str));

String priceChangeModelToJson(PriceChangeModel data) => json.encode(data.toJson());

class PriceChangeModel {
  final List<Today> today;
  final List<Last7Day> last7Days;

  PriceChangeModel({
    required this.today,
    required this.last7Days,
  });

  factory PriceChangeModel.fromJson(Map<String, dynamic> json) => PriceChangeModel(
    today: List<Today>.from(json["TODAY"].map((x) => Today.fromJson(x))),
    last7Days: List<Last7Day>.from(json["LAST 7 DAYS"].map((x) => Last7Day.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "TODAY": List<dynamic>.from(today.map((x) => x.toJson())),
    "LAST 7 DAYS": List<dynamic>.from(last7Days.map((x) => x.toJson())),
  };
}

class Last7Day {
  final String brandName;
  final int last7DaysCount;
  final String last7DaysProductIds;

  Last7Day({
    required this.brandName,
    required this.last7DaysCount,
    required this.last7DaysProductIds,
  });

  factory Last7Day.fromJson(Map<String, dynamic> json) => Last7Day(
    brandName: json["brand_name"],
    last7DaysCount: json["last_7days_count"],
    last7DaysProductIds: json["last_7days_product_ids"],
  );

  Map<String, dynamic> toJson() => {
    "brand_name": brandName,
    "last_7days_count": last7DaysCount,
    "last_7days_product_ids": last7DaysProductIds,
  };
}

class Today {
  final String brandName;
  final List<History> history;

  Today({
    required this.brandName,
    required this.history,
  });

  factory Today.fromJson(Map<String, dynamic> json) => Today(
    brandName: json["brand_name"],
    history: List<History>.from(json["history"].map((x) => History.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "brand_name": brandName,
    "history": List<dynamic>.from(history.map((x) => x.toJson())),
  };
}

class History {
  final int frequency;
  final String updateDate;

  History({
    required this.frequency,
    required this.updateDate,
  });

  factory History.fromJson(Map<String, dynamic> json) => History(
    frequency: json["frequency"],
    updateDate: json["update_date"],
  );

  Map<String, dynamic> toJson() => {
    "frequency": frequency,
    "update_date": updateDate,
  };
}

