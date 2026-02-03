import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cfs_app/src/Destuffing/controller/packageController.dart';
import 'package:cfs_app/src/constants/theme.dart';

class PackagesSubmitScreen extends StatefulWidget {
  final PackagesController controller;

  const PackagesSubmitScreen({super.key, required this.controller});

  @override
  State<PackagesSubmitScreen> createState() => _PackagesSubmitScreenState();
}

class _PackagesSubmitScreenState extends State<PackagesSubmitScreen> {
  final Map<int, bool> selectedPackages = {}; // package id -> selected

  @override
  void initState() {
    super.initState();
    // Initialize selection map for all packages
    for (var pkg in widget.controller.packages) {
      selectedPackages[pkg.id] = false;
    }
  }

  void _submitSelected() {
    final selected =
        widget.controller.packages
            .where((pkg) => selectedPackages[pkg.id] == true)
            .toList();

    if (selected.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No package selected")));
      return;
    }

    // TODO: Call your submit API here with selected packages
    debugPrint("📤 Submitting ${selected.length} packages:");
    for (var pkg in selected) {
      debugPrint(
        "HBL: ${pkg.hblNo}, Qty: ${pkg.packages}, Remarks: ${pkg.remarks}",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Submit Packages",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Obx(() {
        final packages = widget.controller.packages;
        if (packages.isEmpty) {
          return const Center(child: Text("No packages saved yet"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: packages.length,
          itemBuilder: (context, index) {
            final pkg = packages[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: CheckboxListTile(
                value: selectedPackages[pkg.id],
                onChanged: (val) {
                  setState(() => selectedPackages[pkg.id] = val ?? false);
                },
                title: Text("HBL No: ${pkg.hblNo}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Quantity: ${pkg.packages}"),
                    if (pkg.remarks.isNotEmpty) Text("Remarks: ${pkg.remarks}"),
                  ],
                ),
              ),
            );
          },
        );
      }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _submitSelected,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            "Submit Selected Packages",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
