import 'package:cfs_app/src/constants/theme.dart';
import 'package:cfs_app/src/screens/package/packageController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PackagesScreen extends StatelessWidget {
  final int destuffId;

  PackagesScreen({super.key, required this.destuffId}) {
    // register a new controller instance for this destuffId
    Get.put(
      PackagesController(destuffId: destuffId),
      tag: destuffId.toString(), // unique per destuffId
    );
  }

  @override
  Widget build(BuildContext context) {
    // retrieve the controller instance for this destuffId
    final PackagesController ctrl = Get.find(tag: destuffId.toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Packages"),
        backgroundColor: AppColors.primary,
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctrl.packages.isEmpty) {
          return const Center(child: Text("No packages found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.packages.length,
          itemBuilder: (context, index) {
            final pkg = ctrl.packages[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "HBL No: ${pkg.hblNo}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text("Commodity: ${pkg.commodity}"),
                    Text("Status: ${pkg.status}"),
                    Text("Packages: ${pkg.packages}"),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
