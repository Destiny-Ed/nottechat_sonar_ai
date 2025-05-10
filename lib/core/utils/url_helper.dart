import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:notte_chat/core/utils/analysis_logger.dart';
import 'package:path_provider/path_provider.dart';

class UrlHelper {
  // Fetch and process a document from a URL
  static Future<Map<String, dynamic>?> fetchDocumentFromUrl(String url) async {
    try {
       // Validate URL
      final uri = Uri.parse(url);
      if (!uri.isAbsolute) {
        throw Exception('Invalid URL');
      }

      String fetchUrl = url;
      String fileName = url.split('/').last;


      // Handle Google Docs URLs
      bool isGoogleDoc = uri.host.contains('docs.google.com') && uri.path.contains('/document/');
      if (isGoogleDoc) {
        final docId = uri.pathSegments.where((segment) => segment.length > 20 && RegExp(r'^[0-9A-Za-z_-]+$').hasMatch(segment)).firstOrNull;
        if (docId == null) {
          throw Exception('Invalid Google Docs URL');
        }
        // Prefer PDF export for simplicity and compatibility with syncfusion_flutter_pdf
        fetchUrl = 'https://docs.google.com/document/d/$docId/export?format=pdf';
        fileName = '$docId.pdf';
      }

      // Fetch document
      final response = await http.get(Uri.parse(fetchUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch document: ${response.statusCode}. Ensure the document is publicly accessible.');
      }

      // Extract filename from Content-Disposition header
      if (isGoogleDoc) {
        final contentDisposition = response.headers['content-disposition'];
        if (contentDisposition != null) {
          final match = RegExp(r'filename="([^"]+)"').firstMatch(contentDisposition);
          if (match != null && match.group(1) != null) {
            fileName = _sanitizeFileName(match.group(1)!);
            AnalysisLogger.logEvent(
              "filename_extracted",
              EventDataModel(value: "Google Docs - Header"),
            );
          } else {
            AnalysisLogger.logEvent(
              "filename_extracted",
              EventDataModel(value: "Google Docs - Fallback"),
            );
          }
        }
      } else if (response.headers['content-disposition'] != null) {
        final match = RegExp(r'filename="([^"]+)"').firstMatch(response.headers['content-disposition']!);
        if (match != null && match.group(1) != null) {
          fileName = _sanitizeFileName(match.group(1)!);
          AnalysisLogger.logEvent(
            "filename_extracted",
            EventDataModel(value: "Direct URL - Header"),
          );
        }
      }

      // Check content type
      final contentType = response.headers['content-type']?.toLowerCase();
      log("content type :: $contentType");
      if (contentType == null ||
          (!contentType.contains('application/pdf') &&
              !contentType.contains('application/vnd.openxmlformats-officedocument.wordprocessingml.document')) && !contentType.contains("application/msword")) {
        throw Exception('Unsupported file type. Please provide a PDF or Word document URL.');
      }

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(response.bodyBytes);

      Map<String, dynamic> result = {'path': tempFile.path};
       
      return result;
    } catch (e) {
      throw Exception('Error fetching document: $e');
    }
  }

   // Sanitize filename to remove invalid characters
  static String _sanitizeFileName(String fileName) {
    // Remove invalid characters, keep extension
    final sanitized = fileName.replaceAll(RegExp(r'[^\w\s.-]'), '');
    // Ensure it ends with .pdf or .docx for Google Docs or direct URLs
    if (!sanitized.toLowerCase().endsWith('.pdf') && !sanitized.toLowerCase().endsWith('.docx')) {
      return '$sanitized.pdf'; // Default to PDF for Google Docs
    }
    return sanitized;
  }

  // Extract text from PDF
  // static Future<Map<String, dynamic>> _extractPdfText(File file) async {
  //   try {
  //     final bytes = await file.readAsBytes();
  //     final pdfDocument = PdfDocument(inputBytes: bytes);
  //     final extractor = PdfTextExtractor(pdfDocument);
  //     String text = '';
  //     bool wasTruncated = false;
  //     bool isLargeFile = bytes.length > 10 * 1024 * 1024; // >10MB

  //     if (isLargeFile) {
  //       // Extract only first 10 pages for large files
  //       for (int i = 0; i < pdfDocument.pages.count && i < 10; i++) {
  //         text += extractor.extractText(startPageIndex: i, endPageIndex: i);
  //       }
  //       wasTruncated = true;
  //     } else {
  //       text = extractor.extractText();
  //     }

  //     pdfDocument.dispose();
  //     return {'text': text, 'path': file.path, 'isLargeFile': isLargeFile, 'wasTruncated': wasTruncated};
  //   } catch (e) {
  //     throw Exception('Error extracting PDF text: $e');
  //   }
  // }

  // // Extract text from DOCX
  // static Future<Map<String, dynamic>> _extractDocxText(File file) async {
  //   try {
  //     final bytes = await file.readAsBytes();
  //     final archive = ZipDecoder().decodeBytes(bytes);
  //     String text = '';
  //     bool isLargeFile = bytes.length > 10 * 1024 * 1024; // >10MB

  //     // Find document.xml in DOCX archive
  //     final documentFile = archive.findFile('word/document.xml');
  //     if (documentFile != null) {
  //       final content = documentFile.content as List<int>;
  //       final xmlDoc = xml.XmlDocument.parse(String.fromCharCodes(content));
  //       final paragraphs = xmlDoc.findAllElements('w:p');
  //       for (var paragraph in paragraphs) {
  //         final texts = paragraph.findAllElements('w:t');
  //         for (var textNode in texts) {
  //           text += '${textNode.text}\n';
  //         }
  //       }
  //     }

  //     return {
  //       'text': text,
  //       'path': file.path,
  //       'isLargeFile': isLargeFile,
  //       'wasTruncated': false, // DOCX extraction not truncated
  //     };
  //   } catch (e) {
  //     throw Exception('Error extracting DOCX text: $e');
  //   }
  // }
}
