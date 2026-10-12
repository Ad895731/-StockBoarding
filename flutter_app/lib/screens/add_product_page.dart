import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/image_service.dart';
import 'package:image_picker/image_picker.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final categoryController = TextEditingController();
  final mrpController = TextEditingController();
  final quantityController = TextEditingController();
  final sellingPriceController = TextEditingController();
  XFile? selectedImage;
  Uint8List? selectedImageBytes;
  bool isUploadingImage = false;
  String? uploadedImagePath;
  final ImageService imageService = ImageService();

  Future<void> selectImage() async {
    final image = await imageService.pickImage();

    if (image != null) {
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        selectedImage = image;
        selectedImageBytes = bytes;
        uploadedImagePath = null;
      });
    }
  }

  Future<void> uploadSelectedImage() async {
    if (selectedImage == null || selectedImageBytes == null) return;

    setState(() {
      isUploadingImage = true;
    });

    final messenger = ScaffoldMessenger.of(context);

    try {
      final path = await ApiService.uploadImage(
        selectedImage!,
        bytes: selectedImageBytes,
      );

      if (!mounted) return;
      setState(() {
        uploadedImagePath = path;
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text('Uploaded successfully: $path'),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isUploadingImage = false;
        });
      }
    }
  }
  bool isLoading = false;

  Future<void> saveProduct() async {
    if (nameController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await ApiService.createProduct(
        name: nameController.text.trim(),
        brand: brandController.text.trim(),
        category: categoryController.text.trim(),
        mrp: double.tryParse(mrpController.text),
        quantity: quantityController.text.trim(),
        sellingPrice: double.tryParse(sellingPriceController.text),
      );

      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Product saved successfully'),
        ),
      );

      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Picker and Preview Section
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (selectedImageBytes == null)
                      InkWell(
                        onTap: selectImage,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.shade400,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Click to Select Product Image',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          selectedImageBytes!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: isUploadingImage ? null : selectImage,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Change Image'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed:
                                  isUploadingImage ? null : uploadSelectedImage,
                              icon: isUploadingImage
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.cloud_upload_outlined),
                              label: Text(
                                isUploadingImage ? 'Uploading...' : 'Upload Image',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (uploadedImagePath != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green.shade700,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Uploaded: $uploadedImagePath',
                                style: TextStyle(
                                  color: Colors.green.shade900,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
              ),
            ),
            TextField(
              controller: brandController,
              decoration: const InputDecoration(
                labelText: 'Brand',
              ),
            ),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
              ),
            ),
            TextField(
              controller: mrpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'MRP',
              ),
            ),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
              ),
            ),
            TextField(
              controller: sellingPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Selling Price',
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveProduct,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    brandController.dispose();
    categoryController.dispose();
    mrpController.dispose();
    quantityController.dispose();
    sellingPriceController.dispose();

    super.dispose();
  }
}