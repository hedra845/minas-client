import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadService {
  static final Dio _dio = Dio();

  /// Download file from URL and save to device
  static Future<bool> downloadFile({
    required String url,
    required String fileName,
    required BuildContext context,
    Function(double progress)? onProgress,
  }) async {
    try {
      // Request storage permission
      final permission = await Permission.storage.request();
      if (!permission.isGranted) {
        if (context.mounted) {
          _showSnackBar(context, 'Storage permission denied');
        }
        return false;
      }

      // Get downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        if (context.mounted) {
          _showSnackBar(context, 'Could not access storage directory');
        }
        return false;
      }

      final filePath = '${directory.path}/$fileName';

      // Show downloading message
      if (context.mounted) {
        _showSnackBar(context, 'Downloading $fileName...');
      }

      // Download file
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            final progress = received / total;
            onProgress(progress);
          }
        },
      );

      // Show success message
      if (context.mounted) {
        _showSnackBar(context, 'File downloaded successfully');
      }

      // Try to open file after download
      try {
        await OpenFile.open(filePath);
      } catch (e) {
        // Fallback: try to open with url_launcher
        try {
          final uri = Uri.file(filePath);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            if (context.mounted) {
              _showSnackBar(context, 'File downloaded to: $filePath');
            }
          }
        } catch (e2) {
          if (context.mounted) {
            _showSnackBar(context, 'File downloaded to: $filePath');
          }
        }
      }

      return true;
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Failed to download file: ${e.toString()}');
      }
      return false;
    }
  }

  /// Download PDF attachment from reservation
  static Future<bool> downloadReservationAttachment({
    required String attachmentUrl,
    required String reservationId,
    required BuildContext context,
    Function(double progress)? onProgress,
  }) async {
    try {
      // Generate filename
      final fileName = 'reservation_$reservationId.pdf';

      // Check if URL is valid
      if (!attachmentUrl.startsWith('http')) {
        if (context.mounted) {
          _showSnackBar(context, 'Invalid attachment URL');
        }
        return false;
      }

      return await downloadFile(
        url: attachmentUrl,
        fileName: fileName,
        context: context,
        onProgress: onProgress,
      );
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Failed to download attachment');
      }
      return false;
    }
  }

  /// Show snackbar message
  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Check if file is PDF
  static bool isPdfFile(String url) {
    return url.toLowerCase().contains('.pdf') ||
        url.toLowerCase().contains('application/pdf');
  }

  /// Get file name from URL
  static String getFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        return pathSegments.last;
      }
      return 'attachment.pdf';
    } catch (e) {
      return 'attachment.pdf';
    }
  }
}
