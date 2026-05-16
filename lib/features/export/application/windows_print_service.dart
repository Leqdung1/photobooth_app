import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Sends a finalized raster image (PNG/JPEG, etc.) through the Windows print subsystem
/// (spooler → driver → printer) by wrapping it in a single-page PDF and opening the system print dialog.
class WindowsPrintService {
  const WindowsPrintService();

  Future<void> printImageFile(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw StateError('File not found: $imagePath');
    }
    await printImageBytes(await file.readAsBytes());
  }

  Future<void> printImageBytes(Uint8List imageBytes) async {
    await Printing.layoutPdf(
      name: 'photo_booth_final',
      onLayout: (PdfPageFormat format) async {
        final doc = pw.Document();
        final image = pw.MemoryImage(imageBytes);
        doc.addPage(
          pw.Page(
            pageFormat: format,
            build: (context) => pw.Center(
              child: pw.Image(image, fit: pw.BoxFit.contain),
            ),
          ),
        );
        return doc.save();
      },
    );
  }
}
