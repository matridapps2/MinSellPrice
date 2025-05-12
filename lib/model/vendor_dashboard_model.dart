import 'dart:convert';

class VendorDashboardModel {
  final DashboardTotal dashboardTotal;
  final List<TopBrand> topBrands;
  final CompetitiveHealth competitiveHealth;
  final Map<String,dynamic> competitiveHealthAnother;
  final List<DiscountingHealth> discountingHealth;
  final PriceChanges priceChanges;

  VendorDashboardModel({
    required this.dashboardTotal,
    required this.topBrands,
    required this.competitiveHealth,
    required this.competitiveHealthAnother,
    required this.discountingHealth,
    required this.priceChanges,
  });

  factory VendorDashboardModel.fromRawJson(String str) => VendorDashboardModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory VendorDashboardModel.fromJson(Map<String, dynamic> json) => VendorDashboardModel(
    dashboardTotal: DashboardTotal.fromJson(json["DashboardTotal"]),
    topBrands: List<TopBrand>.from(json["TopBrands"].map((x) => TopBrand.fromJson(x))),
    competitiveHealth: CompetitiveHealth.fromJson(json["Competitive Health"]??{}),
    competitiveHealthAnother: json["Competitive Health Another"]??{},
    discountingHealth: List<DiscountingHealth>.from(json["Discounting Health"].map((x) => DiscountingHealth.fromJson(x))),
    priceChanges: PriceChanges.fromJson(json["Price Changes"]),
  );

  Map<String, dynamic> toJson() => {
    "DashboardTotal": dashboardTotal.toJson(),
    "TopBrands": List<dynamic>.from(topBrands.map((x) => x.toJson())),
    "Competitive Health": competitiveHealth.toJson(),
    "Competitive Health Another": competitiveHealthAnother,
    "Discounting Health": List<dynamic>.from(discountingHealth.map((x) => x.toJson())),
    "Price Changes": priceChanges.toJson(),
  };
}

class CompetitiveHealth {
  final String highestBy15;
  final String idHighestBy15;
  final String highestBy5;
  final String idHighestBy5;
  final String highestBy515;
  final String idHighestBy515;
  final String lowestBy15;
  final String idLowestBy15;
  final String lowestBy5;
  final String idLowestBy5;
  final String lowestBy515;
  final String idLowestBy515;

  CompetitiveHealth({
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

  factory CompetitiveHealth.fromRawJson(String str) => CompetitiveHealth.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CompetitiveHealth.fromJson(Map<String, dynamic> json) => CompetitiveHealth(
    highestBy15: json["highest_by_15%"]??'0',
    idHighestBy15: json["id_highest_by_15%"].toString()??'',
    highestBy5: json["highest_by_5%"]??'0',
    idHighestBy5: json["id_highest_by_5%"].toString()??'',
    highestBy515: json["highest_by_5% - 15%"]??'0',
    idHighestBy515: json["id_highest_by_5% - 15%"].toString()??'',
    lowestBy15: json["lowest_by_15%"]??'0',
    idLowestBy15: json["id_lowest_by_15%"].toString()??'',
    lowestBy5: json["lowest_by_5%"]??'0',
    idLowestBy5: json["id_lowest_by_5%"].toString()??'',
    lowestBy515: json["lowest_by_5% - 15%"]??'0',
    idLowestBy515: json["id_lowest_by_5% - 15%"].toString()??'',
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

class CompetitiveHealthAnother {
  final AmericanStandard hansgrohe;
  final AmericanStandard baldwin;
  final AmericanStandard kohler;
  final AmericanStandard toto;
  final AmericanStandard robern;
  final AmericanStandard delta;
  final AmericanStandard newportBrass;
  final AmericanStandard grohe;
  final AmericanStandard moen;
  final AmericanStandard americanStandard;

  CompetitiveHealthAnother({
    required this.hansgrohe,
    required this.baldwin,
    required this.kohler,
    required this.toto,
    required this.robern,
    required this.delta,
    required this.newportBrass,
    required this.grohe,
    required this.moen,
    required this.americanStandard,
  });

  factory CompetitiveHealthAnother.fromRawJson(String str) => CompetitiveHealthAnother.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CompetitiveHealthAnother.fromJson(Map<String, dynamic> json) => CompetitiveHealthAnother(
    hansgrohe: AmericanStandard.fromJson(json["hansgrohe"]),
    baldwin: AmericanStandard.fromJson(json["baldwin"]),
    kohler: AmericanStandard.fromJson(json["kohler"]),
    toto: AmericanStandard.fromJson(json["toto"]),
    robern: AmericanStandard.fromJson(json["robern"]),
    delta: AmericanStandard.fromJson(json["delta"]),
    newportBrass: AmericanStandard.fromJson(json["newport-brass"]),
    grohe: AmericanStandard.fromJson(json["grohe"]),
    moen: AmericanStandard.fromJson(json["moen"]),
    americanStandard: AmericanStandard.fromJson(json["american-standard"]),
  );

  Map<String, dynamic> toJson() => {
    "hansgrohe": hansgrohe.toJson(),
    "baldwin": baldwin.toJson(),
    "kohler": kohler.toJson(),
    "toto": toto.toJson(),
    "robern": robern.toJson(),
    "delta": delta.toJson(),
    "newport-brass": newportBrass.toJson(),
    "grohe": grohe.toJson(),
    "moen": moen.toJson(),
    "american-standard": americanStandard.toJson(),
  };
}

class AmericanStandard {
  final int totalProducts;
  final int lowerMoreThan15;
  final String image;
  final int idLowerMoreThan15;
  final int lowerFrom515;
  final int idLowerFrom515;
  final int lowerUpto5;
  final int idLowerUpto5;
  final int higherUpto5;
  final int idHigherUpto5;
  final int higherFrom515;
  final int idHigherFrom515;
  final int higherMoreThan15;
  final int idHigherMoreThan15;

  AmericanStandard({
    required this.totalProducts,
    required this.lowerMoreThan15,
    required this.image,
    required this.idLowerMoreThan15,
    required this.lowerFrom515,
    required this.idLowerFrom515,
    required this.lowerUpto5,
    required this.idLowerUpto5,
    required this.higherUpto5,
    required this.idHigherUpto5,
    required this.higherFrom515,
    required this.idHigherFrom515,
    required this.higherMoreThan15,
    required this.idHigherMoreThan15,
  });

  factory AmericanStandard.fromRawJson(String str) => AmericanStandard.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AmericanStandard.fromJson(Map<String, dynamic> json) => AmericanStandard(
    totalProducts: json["total_products"],
    lowerMoreThan15: json["lower more than 15%"],
    image: json["Image"],
    idLowerMoreThan15: json["id_lower more than 15%"],
    lowerFrom515: json["lower from 5% - 15%"],
    idLowerFrom515: json["id_lower from 5% - 15%"],
    lowerUpto5: json["lower upto 5%"],
    idLowerUpto5: json["id_lower upto 5%"],
    higherUpto5: json["higher upto 5%"],
    idHigherUpto5: json["id_higher upto 5%"],
    higherFrom515: json["higher from 5% - 15%"],
    idHigherFrom515: json["id_higher from 5% - 15%"],
    higherMoreThan15: json["higher more than 15%"],
    idHigherMoreThan15: json["id_higher more than 15%"],
  );

  Map<String, dynamic> toJson() => {
    "total_products": totalProducts,
    "lower more than 15%": lowerMoreThan15,
    "Image": image,
    "id_lower more than 15%": idLowerMoreThan15,
    "lower from 5% - 15%": lowerFrom515,
    "id_lower from 5% - 15%": idLowerFrom515,
    "lower upto 5%": lowerUpto5,
    "id_lower upto 5%": idLowerUpto5,
    "higher upto 5%": higherUpto5,
    "id_higher upto 5%": idHigherUpto5,
    "higher from 5% - 15%": higherFrom515,
    "id_higher from 5% - 15%": idHigherFrom515,
    "higher more than 15%": higherMoreThan15,
    "id_higher more than 15%": idHigherMoreThan15,
  };
}

class DashboardTotal {
  final int productCount;
  final int scrapData;
  final int priceAutomation;
  final int instock;
  final int outofstock;

  DashboardTotal({
    required this.productCount,
    required this.scrapData,
    required this.priceAutomation,
    required this.instock,
    required this.outofstock,
  });

  factory DashboardTotal.fromRawJson(String str) => DashboardTotal.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DashboardTotal.fromJson(Map<String, dynamic> json) => DashboardTotal(
    productCount: json["product_count"]??0,
    scrapData: json["scrap_data"]??0,
    priceAutomation: json["price_automation"]??0,
    instock: json["instock"]??0,
    outofstock: json["outofstock"]??0,
  );

  Map<String, dynamic> toJson() => {
    "product_count": productCount,
    "scrap_data": scrapData,
    "price_automation": priceAutomation,
    "instock": instock,
    "outofstock": outofstock,
  };
}

class DiscountingHealth {
  final int discountId;
  final int vendorId;
  final String discountValue;
  final String discountBrandType;
  final int discountCount;
  final DateTime discountDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  DiscountingHealth({
    required this.discountId,
    required this.vendorId,
    required this.discountValue,
    required this.discountBrandType,
    required this.discountCount,
    required this.discountDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DiscountingHealth.fromRawJson(String str) => DiscountingHealth.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DiscountingHealth.fromJson(Map<String, dynamic> json) => DiscountingHealth(
    discountId: json["discount_id"],
    vendorId: json["vendor_id"],
    discountValue: json["discount_value"],
    discountBrandType: json["discount_brand_type"],
    discountCount: json["discount_count"],
    discountDate: DateTime.parse(json["discount_date"]),
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "discount_id": discountId,
    "vendor_id": vendorId,
    "discount_value": discountValue,
    "discount_brand_type": discountBrandType,
    "discount_count": discountCount,
    "discount_date": "${discountDate.year.toString().padLeft(4, '0')}-${discountDate.month.toString().padLeft(2, '0')}-${discountDate.day.toString().padLeft(2, '0')}",
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}

class PriceChanges {
  final List<Today> today;
  final List<Last7Day> last7Days;

  PriceChanges({
    required this.today,
    required this.last7Days,
  });

  factory PriceChanges.fromRawJson(String str) => PriceChanges.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PriceChanges.fromJson(Map<String, dynamic> json) => PriceChanges(
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

  factory Last7Day.fromRawJson(String str) => Last7Day.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

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
  final List<PriceHistory> history;

  Today({
    required this.brandName,
    required this.history,
  });

  factory Today.fromRawJson(String str) => Today.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Today.fromJson(Map<String, dynamic> json) => Today(
    brandName: json["brand_name"],
    history: List<PriceHistory>.from(json["history"].map((x) => PriceHistory.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "brand_name": brandName,
    "history": List<dynamic>.from(history.map((x) => x.toJson())),
  };
}

class PriceHistory {
  final int frequency;
  final String updateDate;

  PriceHistory({
    required this.frequency,
    required this.updateDate,
  });

  factory PriceHistory.fromRawJson(String str) => PriceHistory.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PriceHistory.fromJson(Map<String, dynamic> json) => PriceHistory(
    frequency: json["frequency"],
    updateDate: json["update_date"],
  );

  Map<String, dynamic> toJson() => {
    "frequency": frequency,
    "update_date": updateDateValues.reverse[updateDate],
  };
}

enum UpdateDate {
  THE_12062023,
  THE_12072023,
  THE_12082023,
  THE_12092023,
  THE_12102023
}

final updateDateValues = EnumValues({
  "12-06-2023": UpdateDate.THE_12062023,
  "12-07-2023": UpdateDate.THE_12072023,
  "12-08-2023": UpdateDate.THE_12082023,
  "12-09-2023": UpdateDate.THE_12092023,
  "12-10-2023": UpdateDate.THE_12102023
});

class TopBrand {
  final String vendorName;
  final int totalProducts;
  final int totalBrands;
  final Map<String, TopBrandValue> topBrands;

  TopBrand({
    required this.vendorName,
    required this.totalProducts,
    required this.totalBrands,
    required this.topBrands,
  });

  factory TopBrand.fromRawJson(String str) => TopBrand.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TopBrand.fromJson(Map<String, dynamic> json) => TopBrand(
    vendorName: json["vendor_name"],
    totalProducts: json["total_products"],
    totalBrands: json["total_brands"],
    topBrands: Map.from(json["top_brands"]).map((k, v) => MapEntry<String, TopBrandValue>(k, TopBrandValue.fromJson(v))),
  );

  Map<String, dynamic> toJson() => {
    "vendor_name": vendorName,
    "total_products": totalProducts,
    "total_brands": totalBrands,
    "top_brands": Map.from(topBrands).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
  };
}

class TopBrandValue {
  final String image;
  final int count;

  TopBrandValue({
    required this.image,
    required this.count,
  });

  factory TopBrandValue.fromRawJson(String str) => TopBrandValue.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TopBrandValue.fromJson(Map<String, dynamic> json) => TopBrandValue(
    image: json["image"],
    count: json["count"],
  );

  Map<String, dynamic> toJson() => {
    "image": image,
    "count": count,
  };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
