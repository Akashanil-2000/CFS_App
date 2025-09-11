import 'dart:convert';
import 'package:cfs_app/src/models/ContainerModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class DestuffingController extends GetxController {
  var containers = <ContainerModel>[].obs;
  var isLoading = false.obs;

  final String baseUrl = "https://css.odoouae.org/jsonrpc";
  final String db = "css_dmp_mar_25";
  final int uid = 843; // ✅ from login
  final String password = "Akash@1234";

  @override
  void onInit() {
    super.onInit();
    fetchContainers(); // ✅ call automatically when controller is created
  }

  Future<void> fetchContainers() async {
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
          "container.freight.station",
          "search_read",
          [
            ["state", "=", "draft"],
          ],
          [
            "container_number",
            "seal_number",
            "responsible_user_id",
            "origin_id",
            "container_number",
          ],
        ],
      },
      "id": 1,
    };

    try {
      debugPrint("📡 Sending request to $baseUrl ...");

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        debugPrint("✅ Decoded JSON: $result");

        final List data = result["result"] ?? [];
        debugPrint("📊 Containers Count: ${data.length}");

        containers.value = data.map((e) => ContainerModel.fromJson(e)).toList();
      } else {
        debugPrint("❌ HTTP Error: ${response.statusCode}");
        debugPrint("❌ Response Body: ${response.body}");
      }
    } catch (e) {
      debugPrint("🔥 Error fetching containers: $e");
    } finally {
      isLoading(false);
      debugPrint("🏁 fetchContainers() completed");
    }
  }
}
