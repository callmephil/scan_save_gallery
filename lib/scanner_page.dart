import 'dart:async';
import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  List<String> _scannedImages = [];

  @override
  void initState() {
    super.initState();
    _requestPermissions().ignore();
  }

  Future<void> _requestPermissions() async {
    await [Permission.camera, Permission.storage].request();
  }

  Future<void> _onScanDocument() async {
    try {
      final pictures = await CunningDocumentScanner.getPictures();
      if (pictures != null && pictures.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _scannedImages = pictures;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error scanning: $e')));
      }
    }
  }

  Future<void> _saveImages() async {
    if (_scannedImages.isEmpty) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saving images...')));

    var successCount = 0;
    for (final path in _scannedImages) {
      try {
        final file = File(path);
        final bytes = await file.readAsBytes();
        final result = await ImageGallerySaverPlus.saveImage(
          bytes,
          quality: 100,
          name: 'scanned_doc_${DateTime.now().millisecondsSinceEpoch}',
        );

        if (result is! Map || !result.containsKey('isSuccess')) continue;

        if (result['isSuccess'] case final bool success) {
          if (success) {
            successCount++;
          }
        }
      } catch (e) {
        debugPrint('Error saving image $path: $e');
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Saved $successCount of ${_scannedImages.length} images to Gallery!',
          ),
        ),
      );
    }
  }

  void _clearImages() {
    setState(() {
      _scannedImages = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Scanner'),
        actions: [
          if (_scannedImages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _clearImages,
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _scannedImages.isEmpty
                  ? Center(
                      child: Column(
                        spacing: 16,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.document_scanner,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const Text('No documents scanned yet'),
                          ElevatedButton.icon(
                            onPressed: () => unawaited(_onScanDocument()),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Scan Documents'),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: _scannedImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              File(_scannedImages[index]),
                              semanticLabel: 'Scanned Document ${index + 1}',
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: DecoratedBox(
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            if (_scannedImages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  spacing: 16,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => unawaited(_onScanDocument()),
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('Scan More'),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => unawaited(_saveImages()),
                        icon: const Icon(Icons.save),
                        label: const Text('Save to Gallery'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
