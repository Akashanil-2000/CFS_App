import 'dart:convert';
import 'package:cfs_app/src/Destuffing/models/ContainerModel.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class DestuffingController extends GetxController {
  var containers = <ContainerModel>[].obs;
  var isLoading = false.obs;

  final String baseUrl = "https://css.odoouae.org/jsonrpc";
  final String db = "css_dmp_mar_25";

  final box = GetStorage(); // ✅ use same storage as login

  int get uid => box.read('userId') ?? 0;
  String get password => box.read('password') ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchContainers();
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
            // "|",
            // ["state", "=", "destuff_process"],
            // ["state", "=", "ready_to_destuff"],
            ["state", "=", "over"],
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
      debugPrint("📡 Sending request to $baseUrl with UID=$uid ...");

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        debugPrint("✅ Decoded JSON: $result");

        final List data = result["result"] ?? [];
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

  Future<void> updateDestuffStatus(int id, String action) async {
    final now = DateTime.now().toUtc().toIso8601String();

    Map<String, dynamic> values = {};
    if (action == 'start') {
      values = {
        "destuff_start": now,
        "destuff_status": "in_progress",
        "state": "destuff_process",
        "destuff_hold_duration": 0,
      };
    } else if (action == 'stop') {
      values = {
        "destuff_stop": now,
        "destuff_status": "completed",
        "state": "destuff_process",
        "destuff_last_hold_time": null,
      };
    }

    final body = {
      "jsonrpc": "2.0",
      "method": "call",
      "params": {
        "service": "object",
        "method": "execute_kw",
        "args": [
          db,
          uid,
          password,
          "container.freight.station",
          "write",
          [
            [id], // record id
            values,
          ],
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
        debugPrint("✅ $action success for container $id");
      } else {
        debugPrint("❌ Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      debugPrint("🔥 updateDestuffStatus failed: $e");
    }
  }
}
