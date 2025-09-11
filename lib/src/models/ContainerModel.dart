class ContainerModel {
  final int id;
  final int? destuffId; // new field
  final String? containerNumber;
  final String? sealNumber;
  final String? customerStatus;
  final String? origin;

  ContainerModel({
    required this.id,
    this.destuffId,
    this.containerNumber,
    this.sealNumber,
    this.customerStatus,
    this.origin,
  });

  factory ContainerModel.fromJson(Map<String, dynamic> json) {
    return ContainerModel(
      id: json['id'],
      destuffId: json['destuff_id'] != null ? json['destuff_id'] : null,
      containerNumber:
          json['container_number'] != false ? json['container_number'] : null,
      sealNumber: json['seal_number'] != false ? json['seal_number'] : null,
      customerStatus:
          json['responsible_user_id'] != false
              ? json['responsible_user_id'][1]
              : null,
      origin: json['origin_id'] != false ? json['origin_id'][1] : null,
    );
  }
}
