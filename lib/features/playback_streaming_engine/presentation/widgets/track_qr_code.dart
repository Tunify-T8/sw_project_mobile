import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TrackQrCode extends StatelessWidget {
  const TrackQrCode({super.key, required this.data, this.size = 300});

  final String data;
  final double size;

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Colors.black,
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Colors.black,
      ),
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );
  }
}
