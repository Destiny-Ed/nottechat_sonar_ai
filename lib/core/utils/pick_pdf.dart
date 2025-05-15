import 'dart:developer';
import 'dart:io';
import 'package:doc_text_extractor/doc_text_extractor.dart';
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

Future<String> extractLocalText(String filePath ) async {
   final extractor = TextExtractor();
 
  String getText = "";

  try {
    final extractedText = await extractor.extractText(filePath, isUrl: false);

    getText = extractedText.text;

  } catch (e) {
    log("${e.toString()}");
    getText = "";
  }

  return getText;
}

