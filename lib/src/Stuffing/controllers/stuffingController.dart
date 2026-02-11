import 'dart:convert';

import 'package:cfs_app/src/Stuffing/models/ContainerModel.dart';
import 'package:cfs_app/src/constants/url_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class StuffingController extends GetxController {
  var containers = <StuffingContainerModel>[].obs;
  var isLoading = false.obs;

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
            ["schedule_type", "=", "outgoing"],
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
        containers.value =
            data.map((e) => StuffingContainerModel.fromJson(e)).toList();
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

  Future<void> updateStuffingStatus(int id, String action) async {
    final now = DateTime.now().toUtc().toIso8601String();

    Map<String, dynamic> values = {};
    if (action == 'start') {
      values = {
        "stuffing_start": now,
        "stuffing_status": "in_progress",
        "state": "stuffing_process",
        "stuffing_hold_duration": 0,
      };
    } else if (action == 'stop') {
      values = {
        "stuffing_stop": now,
        "stuffing_status": "completed",
        "state": "stuffing_process",
        "stuffing_last_hold_time": null,
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
      debugPrint("🔥 updateStuffingStatus failed: $e");
    }
  }
}
