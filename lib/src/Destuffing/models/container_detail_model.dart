class ContainerDetailModel {
  final String? name;
  final String? customStatus;
  final String? paymentStatus;
  final String? containerType;
  final String? containerNumber;
  final String? sealNumber;
  final String? requestDate;
  final String? priority;
  final String? priorityRemarks;
  final String? originCountry;
  final String? origin;
  final int? hblCount;
  final String? packagesUom;
  final String? weightUom;
  final String? volumeUom;

  ContainerDetailModel({
    this.name,
    this.customStatus,
    this.paymentStatus,
    this.containerType,
    this.containerNumber,
    this.sealNumber,
    this.requestDate,
    this.priority,
    this.priorityRemarks,
    this.originCountry,
    this.origin,
    this.hblCount,
    this.packagesUom,
    this.weightUom,
    this.volumeUom,
  });

  factory ContainerDetailModel.fromJson(Map<String, dynamic> json) {
    return ContainerDetailModel(
      name: json["name"],
      customStatus: json["custom_status"],
      paymentStatus: json["payment_status"],
      containerType:
          json["container_type_id"] != false
              ? json["container_type_id"][1]
              : null,
      containerNumber:
          json["container_number"] != false ? json["container_number"] : null,
      sealNumber: json["seal_number"],
      requestDate: json["request_date"],
      priority: json["priority"],
      priorityRemarks: json["priority_remarks"],
      originCountry:
          json["origin_country_id"] != false
              ? json["origin_country_id"][1]
              : null,
      origin: json["origin_id"] != false ? json["origin_id"][1] : null,
      hblCount: json["hbl_count"],
      packagesUom:
          json["mbl_packages_uom"] != false
              ? json["mbl_packages_uom"][1]
              : null,
      weightUom:
          json["mbl_weight_uom"] != false ? json["mbl_weight_uom"][1] : null,
      volumeUom:
          json["mbl_volume_uom"] != false ? json["mbl_volume_uom"][1] : null,
    );
  }
}
