import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cfs_app/src/Destuffing/controller/packageController.dart';
import 'package:cfs_app/src/constants/theme.dart';

class AddPackageScreen extends StatefulWidget {
  final String hblNo;
  final PackagesController controller;

  const AddPackageScreen({
    super.key,
    required this.hblNo,
    required this.controller,
  });

  @override
  State<AddPackageScreen> createState() => _AddPackageScreenState();
}

class _AddPackageScreenState extends State<AddPackageScreen> {
  final TextEditingController qtyCtrl = TextEditingController();
  final TextEditingController conditionCtrl = TextEditingController();
  final TextEditingController marksCtrl = TextEditingController();
  final TextEditingController remarksCtrl = TextEditingController();

  List<File> _images = [];
  String? selectedRemark;

  Future<void> _pickImage() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
      );
      if (pickedFile != null) {
        setState(() => _images.add(File(pickedFile.path)));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Camera permission denied")));
    }
  }

  void _save() {
    if (qtyCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter quantity")));
      return;
    }

    final qty = int.tryParse(qtyCtrl.text) ?? 0;
    widget.controller.addPackage(
      widget.hblNo,
      qty,
      condition: conditionCtrl.text,
      marks: marksCtrl.text,
      remarks: selectedRemark ?? "",
      images: _images,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Package - ${widget.hblNo}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ), // 🔹 Back button color
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInputCard(),
            const SizedBox(height: 20),
            _buildImageCard(),
            const SizedBox(height: 30),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(qtyCtrl, "Quantity", TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField(conditionCtrl, "Condition"),
            const SizedBox(height: 16),
            _buildTextField(marksCtrl, "Marks & Number"),
            const SizedBox(height: 16),
            _buildRemarksDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: const Text(
                "Add Photo",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_images.isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _images[index],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: -8,
                            right: -8,
                            child: IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () {
                                setState(() => _images.removeAt(index));
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemarksDropdown() {
    return Obx(() {
      final items = widget.controller.remarksList;
      if (items.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return DropdownButtonFormField<String>(
        isExpanded: true,
        value: selectedRemark,
        decoration: InputDecoration(
          labelText: "Remarks",
          filled: true,
          fillColor: Colors.grey[100],
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        items:
            items
                .map(
                  (remark) => DropdownMenuItem(
                    value: remark,
                    child: Text(remark, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
        onChanged: (val) => setState(() => selectedRemark = val),
      );
    });
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _save,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AppColors.primary,
          elevation: 5,
        ),
        child: const Text(
          "Save Package",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, [
    TextInputType type = TextInputType.text,
  ]) {
    return TextField(
      controller: controller,
      keyboardType: type,
      cursorColor: Colors.black, // 🔹 Cursor color
      style: const TextStyle(color: Colors.black), // Text color
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black), // Label color
        floatingLabelStyle: const TextStyle(
          color: Colors.black,
        ), // Floating label color
        filled: true,
        fillColor: Colors.grey[100],
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
      ),
    );
  }
}
