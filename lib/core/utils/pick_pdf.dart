import 'dart:developer';
import 'dart:io';

import 'package:docx_to_text/docx_to_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

// Future<File?> pickPDF() async {
//   FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
//   if (result != null && result.files.single.path != null) {
//     File pdfFile = File(result.files.single.path!);
//     return pdfFile;
//   }
//   return null;
// }

// Future<List<File>> pickDocuments() async {
//   FilePickerResult? result = await FilePicker.platform.pickFiles(
//     allowMultiple: true,
//     type: FileType.custom,
//     allowedExtensions: ['pdf', "docx"],
//   );
//   if (result != null && result.files.isNotEmpty) {
//     List<File> pdfFiles = result.files.map((file) => File(file.path!)).toList();
//     return pdfFiles;
//   }
//   return [];
// }
Future<List<PlatformFile>> pickDocuments() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'doc'],
    );
    if (result != null && result.files.isNotEmpty) {
      return result.files;
    }
    return [];
  } catch (e, stackTrace) {
    log('Error picking documents: $e');
    log('Stack trace: $stackTrace');
    return [];
  }
}

Future<String> extractText(PlatformFile file) async {
  final isPdfFile = file.extension!.toLowerCase() == "pdf";
  String getText = "";
  print("isPDF File :: $isPdfFile");

  try {
    if (isPdfFile) {
      print("Extracting file");
      // final getPDF = await ReadPdfText.getPDFtext(file.path).timeout(Duration(seconds: 5));
      // getText = await getPDF;

      final PdfDocument document = PdfDocument(inputBytes: kIsWeb ? file.bytes : await File(file.path!).readAsBytes());
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      final String text = extractor.extractText();
      getText = text;
      document.dispose(); // Free memory

      print("text :: $getText");
    } 
    else if (file.extension!.toLowerCase() == "docx") {
      print(file.path);
      final String? extractedText = await docxToText(kIsWeb ? file.bytes! : await File(file.path!).readAsBytes());
      getText = extractedText ?? "";
    }
    else {
      final String? extractedText = await _extractDocText(file);
      getText = extractedText ?? "";
    }
  } on PlatformException catch (e) {
    log("Error Extracting Document from (${isPdfFile ? "pdf" : "docx"}) : ${e.toString()}");
    getText = "";
  }

  return getText;
}


// Extract text from DOC
    Future<String?> _extractDocText(PlatformFile file) async {
    try {
      final bytes = await File(file.path!).readAsBytes();
      final byteData = ByteData.sublistView(bytes);
      String text = '';
      // bool isLargeFile = bytes.length > 10 * 1024 * 1024; // >10MB

      // Basic binary parser for .doc text
      // Scan for printable ASCII/Unicode characters (32-126, basic Latin)
      final buffer = StringBuffer();
      bool inTextSegment = false;
      int textLength = 0;

      for (int i = 0; i < bytes.length && textLength < 100000; i++) {
        final byte = byteData.getUint8(i);
        if (byte >= 32 && byte <= 126) {
          // Printable ASCII character
          buffer.writeCharCode(byte);
          inTextSegment = true;
          textLength++;
        } else if (byte == 13 || byte == 10) {
          // Carriage return or newline
          if (inTextSegment) {
            buffer.write('\n');
            textLength++;
          }
        } else {
          // Non-text byte (e.g., formatting, metadata)
          if (inTextSegment && buffer.isNotEmpty) {
            text += '${buffer.toString()}\n';
            buffer.clear();
            inTextSegment = false;
          }
        }
      }

      // Append any remaining text
      if (buffer.isNotEmpty) {
        text += buffer.toString();
      }

      // Clean up extracted text
      text = text.replaceAll(RegExp(r'\n\s*\n+'), '\n').trim();
      if (text.isEmpty) {
        throw Exception('No readable text found in .doc file');
      }
      return text;
    } catch (e) {
      throw Exception('Error extracting .doc text: File may be corrupted or unsupported. Try converting to .docx or PDF.');
    }
  }