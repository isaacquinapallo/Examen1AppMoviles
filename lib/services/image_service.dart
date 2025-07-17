import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageService {
  static final _supabase = Supabase.instance.client;
  static final _picker = ImagePicker();

  static const int maxFileSize = 5 * 1024 * 1024; // 5 MB
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  /// Validar archivo por extensión y tamaño (desde XFile)
  static Future<bool> _validateXFile(XFile xfile, BuildContext context) async {
    final ext = path.extension(xfile.name).replaceFirst('.', '').toLowerCase();
    final bytes = await xfile.length();

    if (!allowedExtensions.contains(ext)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Formato no permitido: $ext')),
        );
      }
      return false;
    }

    if (bytes > maxFileSize) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La imagen excede el tamaño máximo permitido (5 MB).')),
        );
      }
      return false;
    }

    return true;
  }

  /// Subir una sola imagen
  static Future<String?> uploadImage(XFile xfile, String bucketName) async {
    try {
      final ext = path.extension(xfile.name).replaceFirst('.', '').toLowerCase();

      if (!allowedExtensions.contains(ext)) {
        debugPrint("Formato no permitido: $ext");
        return null;
      }

      final bytes = await xfile.readAsBytes();

      if (bytes.length > maxFileSize) {
        debugPrint("Archivo demasiado grande: ${bytes.length}");
        return null;
      }

      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.$ext';

      final response = await _supabase.storage.from(bucketName).uploadBinary(
        fileName,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );

      if (response.isNotEmpty) {
        return _supabase.storage.from(bucketName).getPublicUrl(fileName);
      }
      return null;
    } catch (e) {
      debugPrint('Error subiendo imagen: $e');
      return null;
    }
  }

  /// Subir múltiples imágenes (máx. 5)
  static Future<List<String>> uploadMultipleImages(List<XFile> xfiles, String bucketName) async {
    final limitedFiles = xfiles.length > 5 ? xfiles.sublist(0, 5) : xfiles;
    List<String> imageUrls = [];

    for (final xfile in limitedFiles) {
      final url = await uploadImage(xfile, bucketName);
      if (url != null) {
        imageUrls.add(url);
      }
    }

    return imageUrls;
  }

  /// Mostrar opciones de selección de imagen (galería o cámara)
  static Future<List<XFile>?> showImageOptions(BuildContext context) async {
    List<XFile> selectedImages = [];

    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const Text('Selecciona una opción', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.teal),
                title: const Text('Galería (hasta 5 imágenes)'),
                onTap: () => Navigator.of(context).pop('gallery'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.orange),
                title: const Text('Cámara'),
                onTap: () => Navigator.of(context).pop('camera'),
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Cancelar'),
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (result == 'gallery') {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 80);
      final limitedImages = images.length > 5 ? images.sublist(0, 5) : images;

      for (final xfile in limitedImages) {
        if (await _validateXFile(xfile, context)) {
          selectedImages.add(xfile);
        }
      }
    } else if (result == 'camera') {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (image != null && await _validateXFile(image, context)) {
        selectedImages.add(image);
      }
    }

    if (context.mounted && selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se seleccionaron imágenes válidas.')),
      );
    }

    return selectedImages.isNotEmpty ? selectedImages : null;
  }
}
