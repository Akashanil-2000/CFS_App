class PackageModel {
  final int id;
  final String hblNo;
  final String commodity;
  final String status;
  final int packages;

  PackageModel({
    required this.id,
    required this.hblNo,
    required this.commodity,
    required this.status,
    required this.packages,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'],
      hblNo: json['hbl_no'] ?? "-",
      commodity: json['commodity'] ?? "-",
      status: json['status'] ?? "-",
      packages: json['packages'] ?? 0,
    );
  }
}
