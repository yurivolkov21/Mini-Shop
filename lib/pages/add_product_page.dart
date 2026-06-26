import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../api/cloudinary_repo.dart';
import '../api/product_repo.dart';

class AddProductPage extends StatefulWidget {
  /// Truyền `existing` (Map sản phẩm) để vào chế độ Sửa; null = Thêm mới.
  final Map<String, dynamic>? existing;
  const AddProductPage({super.key, this.existing});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _cloudinary = CloudinaryRepo();
  final _products = ProductRepo();
  final _picker = ImagePicker();

  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController(text: 'general');
  final _descCtrl = TextEditingController();

  File? _image; // ảnh mới chọn (nếu có)
  String? _existingImageUrl; // ảnh cũ khi sửa
  bool _saving = false;
  double _uploadProgress = 0;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _nameCtrl.text = (e['name'] ?? '').toString();
      _priceCtrl.text = (e['price'] ?? '').toString();
      _categoryCtrl.text = (e['category'] ?? 'general').toString();
      _descCtrl.text = (e['description'] ?? '').toString();
      _existingImageUrl = e['imageUrl'] as String?;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _categoryCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _uploadProgress = 0;
    });
    try {
      // 1. Có ảnh mới -> upload Cloudinary lấy URL; nếu sửa mà không đổi ảnh -> giữ URL cũ
      String? imageUrl = _existingImageUrl;
      if (_image != null) {
        final img = await _cloudinary.uploadImage(
          _image!,
          onProgress: (p) => setState(() => _uploadProgress = p),
        );
        imageUrl = img.url;
      }
      // 2. Tạo hoặc cập nhật
      final name = _nameCtrl.text.trim();
      final price = num.parse(_priceCtrl.text.trim());
      final category = _categoryCtrl.text.trim().isEmpty
          ? 'general'
          : _categoryCtrl.text.trim();
      final description = _descCtrl.text.trim();
      if (_isEdit) {
        await _products.updateProduct(
          id: widget.existing!['_id'] as String,
          name: name,
          price: price,
          category: category,
          description: description,
          imageUrl: imageUrl,
        );
      } else {
        await _products.createProduct(
          name: name,
          price: price,
          category: category,
          description: description,
          imageUrl: imageUrl,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEdit ? 'Đã cập nhật!' : 'Đã tạo sản phẩm!')),
      );
      Navigator.pop(context, true); // trả true để màn trước refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _imagePreview() {
    if (_image != null) {
      return Image.file(_image!, fit: BoxFit.cover);
    }
    if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      return Image.network(_existingImageUrl!, fit: BoxFit.cover);
    }
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_a_photo, size: 40),
          SizedBox(height: 8),
          Text('Chọn ảnh sản phẩm'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Sửa sản phẩm' : 'Thêm sản phẩm'),
      ),
      body: AbsorbPointer(
        absorbing: _saving,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _imagePreview(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên sản phẩm',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nhập tên' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Giá',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Nhập giá';
                    if (num.tryParse(v.trim()) == null) return 'Giá phải là số';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _categoryCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Danh mục',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả (tuỳ chọn)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                if (_saving && _uploadProgress > 0 && _uploadProgress < 1) ...[
                  LinearProgressIndicator(value: _uploadProgress),
                  const SizedBox(height: 4),
                  Text('Đang upload ảnh ${(_uploadProgress * 100).toStringAsFixed(0)}%'),
                  const SizedBox(height: 12),
                ],
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_saving
                      ? 'Đang lưu...'
                      : (_isEdit ? 'Cập nhật' : 'Lưu sản phẩm')),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
