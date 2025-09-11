import 'package:cfs_app/src/constants/theme.dart';
import 'package:flutter/material.dart';

class OutrunPackagesScreen extends StatelessWidget {
  final String packageId;

  const OutrunPackagesScreen({super.key, required this.packageId});

  @override
  Widget build(BuildContext context) {
    // raw details (can be replaced by API later)
    final List<Map<String, String>> packageDetails = [
      {"count": "10", "uom": "Boxes", "description": "Electronics items"},
      {"count": "5", "uom": "Cartons", "description": "Clothing materials"},
      {"count": "20", "uom": "Packets", "description": "Food supplies"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Outrun Packages - $packageId"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: packageDetails.length,
          itemBuilder: (context, index) {
            final pkg = packageDetails[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  "Count: ${pkg['count']} ${pkg['uom']}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(pkg['description'] ?? ""),
              ),
            );
          },
        ),
      ),

      // Submit button at bottom
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            // TODO: handle submission logic
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Packages submitted successfully!")),
            );
          },
          child: const Text(
            "Submit",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
