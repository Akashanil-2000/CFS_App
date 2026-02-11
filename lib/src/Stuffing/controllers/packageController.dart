import 'dart:convert';
import 'dart:io';
import 'package:cfs_app/src/Destuffing/models/packageModel.dart';
import 'package:cfs_app/src/constants/url_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class PackagesController extends GetxController {
  var packages = <PackageModel>[].obs;
  var remarksList = <String>[].obs;
  var isLoading = false.obs;

  final int destuffId;
  PackagesController({required this.destuffId});

  final box = GetStorage(); // ✅ Access saved login data

  int get uid => box.read('userId') ?? 0;
  String get password => box.read('password') ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchPackages();
    fetchRemarks();
  }

  Future<void> fetchPackages() async {
    isLoading(true);

    final body = {
      "jsonrpc": "2.0",
      "method": "execute",
      "params": {
        "service": "object",
        "method": "execute",
        "args": [
          db,
          uid,
          password,
          "dimension.line",
          "search_read",
          [
            ["destuff_id", "=", destuffId],
          ],
          ["hbl_no", "commodity", "status", "packages"],
        ],
      },
      "id": 1,
    };

    try {
      debugPrint("📡 Fetching packages for destuffId=$destuffId, UID=$uid");

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final List data = result['result'] ?? [];
        packages.value = data.map((e) => PackageModel.fromJson(e)).toList();
      } else {
        debugPrint("❌ HTTP Error: ${response.statusCode}");
        debugPrint("❌ Response Body: ${response.body}");
      }
    } catch (e) {
      debugPrint("🔥 Error fetching packages: $e");
    } finally {
      isLoading(false);
    }
  }

  void addPackage(
    String hblNo,
    int qty, {
    String condition = "",
    String marks = "",
    String remarks = "",
    List<File>? images,
  }) {
    packages.add(
      PackageModel(
        id: DateTime.now().millisecondsSinceEpoch,
        hblNo: hblNo,
        commodity: "Custom",
        status: "added",
        packages: qty,
        condition: condition,
        marks: marks,
        remarks: remarks,
        images: images ?? [],
      ),
    );
    update();
  }

  Future<void> fetchRemarks() async {
    final body = {
      "jsonrpc": "2.0",
      "method": "execute",
      "params": {
        "service": "object",
        "method": "execute",
        "args": [
          "css_dmp_mar_25", // db
          uid, // user id
          password, // password
          "cfs.cargo.remarks", // model
          "search_read", // method
          [], // domain
          ["name"], // fields
        ],
      },
      "id": 1,
    };

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final List data = result['result'] ?? [];
        remarksList.value =
            data.map<String>((e) => e['name'].toString()).toList();
      } else {
        debugPrint("❌ Remarks HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("🔥 Error fetching remarks: $e");
    }
  }

  void submitPackages() {
    debugPrint(
      "📤 Submitting ${packages.length} packages for destuff $destuffId",
    );
    // TODO: implement submit API call
  }

  void printPackages() {
    debugPrint("🖨️ Printing packages...");
    // TODO: implement print functionality
  }
}
