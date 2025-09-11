import 'dart:convert';

import 'package:cfs_app/src/models/packageModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class PackagesController extends GetxController {
  var packages = <PackageModel>[].obs;
  var isLoading = false.obs;

  final int destuffId;

  PackagesController({required this.destuffId});

  final String baseUrl = "https://css.odoouae.org/jsonrpc";
  final String db = "css_dmp_mar_25";
  final int uid = 843;
  final String password = "Akash@1234";

  @override
  void onInit() {
    super.onInit();
    fetchPackages();
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
            ["status", "=", "not_picked"],
            ["destuff_id", "=", destuffId],
          ],
          ["hbl_no", "commodity", "status", "packages"],
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
        packages.value = data.map((e) => PackageModel.fromJson(e)).toList();
      } else {
        debugPrint("HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching packages: $e");
    } finally {
      isLoading(false);
    }
  }
}
