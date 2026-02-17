import 'dart:convert';
import 'package:cfs_app/src/Destuffing/models/ContainerModel.dart';
import 'package:cfs_app/src/Destuffing/models/container_detail_model.dart';
import 'package:cfs_app/src/constants/url_constants.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class DestuffingController extends GetxController {
  var containers = <ContainerModel>[].obs;
  var isLoading = false.obs;

  final box = GetStorage(); // ✅ use same storage as login

  int get uid => box.read('userId') ?? 0;
  String get password => box.read('password') ?? '';

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchContainers();
    });
  }

  Future<void> fetchContainers() async {
    safeLoading(true);

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
            ["schedule_type", "=", "incoming"],
          ],
          [
            "container_number",
            "seal_number",
            "responsible_user_id",
            "origin_id",
            "container_number",
            "state",
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
      safeLoading(false);
      debugPrint("🏁 fetchContainers() completed");
    }
  }

  void safeLoading(bool value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      safeLoading(value);
    });
  }

  var detail = Rxn<ContainerDetailModel>();

  Future<void> fetchContainerDetail(int id) async {
    safeLoading(true);

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
            ["id", "=", id],
          ],
          [
            "name",
            "custom_status",
            "payment_status",
            "container_type_id",
            "container_number",
            "seal_number",
            "request_date",
            "priority",
            "priority_remarks",
            "origin_country_id",
            "origin_id",
            "hbl_count",
            "mbl_packages_uom",
            "mbl_weight_uom",
            "mbl_volume_uom",
          ],
        ],
      },
      "id": 1,
    };

    try {
      final res = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final result = jsonDecode(res.body);
      final data = result["result"][0];
      detail.value = ContainerDetailModel.fromJson(data);
    } catch (e) {
      debugPrint("Detail Error: $e");
    } finally {
      safeLoading(false);
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
