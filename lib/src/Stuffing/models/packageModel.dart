import 'dart:io';

class PackageModel {
  final int id;
  final String hblNo;
  final String commodity;
  final String status;
  final int packages;
  final String condition;
  final String marks;
  final String remarks;
  final List<File> images;

  PackageModel({
    required this.id,
    required this.hblNo,
    required this.commodity,
    required this.status,
    required this.packages,
    this.condition = "",
    this.marks = "",
    this.remarks = "",
    this.images = const [],
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'],
      hblNo: json['hbl_no'] ?? "-",
      commodity: json['commodity'] ?? "-",
      status: json['status'] ?? "-",
      packages: json['packages'] ?? 0,
      condition: json['condition'] ?? "",
      marks: json['marks'] ?? "",
      remarks: json['remarks'] ?? "",
      images: [], // for now, deserialize later if needed
    );
  }
}
