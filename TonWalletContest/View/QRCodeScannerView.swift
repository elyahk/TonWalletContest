//
//  QRCodeScannerView.swift
//  TonWalletContest
//
//  Created by Viacheslav on 06/05/23.
//

import SwiftUI
import AVFoundation

final class QRCodeScannerDelegate: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = metadataObject.stringValue else {
            return
        }

        print("\(stringValue)")
    }
}

struct QRCodeScannerView: View {
    private var captureScreen = AVCaptureSession()
    private let delegate = QRCodeScannerDelegate()

    var body: some View {
        ZStack {
            CameraPreview(session: captureScreen)
        }
        .onAppear {
            self.setupCaptureSession()
            self.captureScreen.startRunning()
        }
        .onDisappear {
            self.captureScreen.stopRunning()
        }
    }

    func setupCaptureSession() {
        guard let captureDevice = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            return
        }

        let metaDataOutput = AVCaptureMetadataOutput()
        if self.captureScreen.canAddInput(input) && self.captureScreen.canAddOutput(metaDataOutput) {
            self.captureScreen.addInput(input)
            self.captureScreen.addOutput(metaDataOutput)

            metaDataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
            metaDataOutput.metadataObjectTypes = [.qr]
        }
    }
}

struct CameraPreview: UIViewRepresentable {

    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let cameraView = UIView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)

        previewLayer.frame = cameraView.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        cameraView.layer.addSublayer(previewLayer)

        return cameraView

    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer else {
            return
        }

        previewLayer.frame = uiView.layer.bounds
    }
}

struct QRCodeScannerView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeScannerView()
    }
}
