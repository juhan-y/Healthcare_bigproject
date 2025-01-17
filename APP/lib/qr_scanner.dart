import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

// QR Scanner 페이지
class QRCheckScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/qr_scanner';

  final String eventKeyword; //건져올 특정 키워드

  QRCheckScreen({required this.eventKeyword});

  @override
  State<QRCheckScreen> createState() => _QRCheckScreenState();
}

class _QRCheckScreenState extends State<QRCheckScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(title: Text('QR Scanner')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: this._onQRViewCreated,
                  formatsAllowed: [
                    BarcodeFormat.qrcode
                  ],
                  overlay: QrScannerOverlayShape(
                    borderRadius: 10,
                    borderColor: Colors.blue,
                    borderLength: 30,
                    borderWidth: 5,
                    cutOutSize: screenSize.width/1.4,
                  ),
                ),
              ),
            )
          ],
        ));
  }

  // QR Code를 카메라로 받고 원하는 정보가 들어있을 때만 종료
  // 페이지 종료시에는 받은 정보를 전달
  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.resumeCamera();

    controller.scannedDataStream.listen((event) {

      if (event.code != null) {
        //스캔된 QR코드에 특정 키워드가 들어있다면
        //QR스캔을 정지하고 이 화면을 닫으면서 QR결과값을 보내주도록한다.
        // this.controller!.dispose();
        if (event.code!.contains(widget.eventKeyword)) {
          print('QR Code detected !!!');
          this.controller!.dispose();
          Navigator.pop(context, event.code);
        }
      }
    });
  }
}