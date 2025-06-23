//
//  QRScanViewController.swift
//  VoiAssignment
//
//  Created by Gayatri Nagarkar on 2025-06-23.
//

import UIKit
import Combine
import AVFoundation

protocol QRScanProtocol {
    var actionPublisher: PassthroughSubject<QRScanResult, Never> { get }
}

class QRScanViewController: UIViewController {
    
    let actionPublisher = PassthroughSubject<QRScanResult, Never>()
    let cameraSessionQueue = DispatchQueue(label: "cameraSessionQueue", qos: .userInitiated)
    
    var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            var isAuthorized = status == .authorized
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            return isAuthorized
        }
    }
    
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.accessibilityIdentifier = AccessibilityIDs.qrScanView.view
        setupCaptureSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
    }
    
    // MARK: - Private methods
    private func setupCaptureSession() {
        checkPermission()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            publish(.videoCaptureDeviceNotAvailable)
            return
        }
        
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            publish(.videoCaptureDeviceNotAvailable)
            return
        }
        
        guard captureSession.canAddInput(videoInput) else {
            publish(.videoCaptureDeviceNotAvailable)
            return
        }
        captureSession.addInput(videoInput)
        
        setupMetadataOutput()
        setupPreviewLayer()
        startSession()
    }
    
    private func checkPermission() {
        Task {
            guard await isAuthorized else {
                publish(.cameraPermissionNotAvailable)
                return
            }
        }
    }
    
    private func setupMetadataOutput() {
        let metadataOutput = AVCaptureMetadataOutput()
        
        guard captureSession.canAddOutput(metadataOutput) else {
            publish(.qrScanningNotSupported)
            return
        }
        captureSession.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
        metadataOutput.metadataObjectTypes = [.qr]
    }
    
    private func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        guard let previewLayer else {
            return
        }
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }
    
    private func startSession() {
        cameraSessionQueue.async {
            if self.captureSession.isRunning {
                return
            }
            self.captureSession.startRunning()
        }
    }
    
    private func stopSession() {
        cameraSessionQueue.async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
    
    private func publish(_ result: QRScanResult) {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            
            switch result {
            case .qrCode(let text):
                actionPublisher.send(.qrCode(text))
            case .cameraPermissionNotAvailable:
                actionPublisher.send(.cameraPermissionNotAvailable)
            case .videoCaptureDeviceNotAvailable:
                actionPublisher.send(.videoCaptureDeviceNotAvailable)
            case .qrScanningNotSupported:
                actionPublisher.send(.qrScanningNotSupported)
            }
        }
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate -
extension QRScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        stopSession()
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let stringValue = metadataObject.stringValue {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            publish(.qrCode(stringValue))
        }
    }
}

// MARK: - QRScanResult -
enum QRScanResult {
    case qrCode(String)
    case cameraPermissionNotAvailable
    case videoCaptureDeviceNotAvailable
    case qrScanningNotSupported
    
    var errorMessage: String? {
        switch self {
        case .qrCode:
            return nil
        case .cameraPermissionNotAvailable:
            return "Camera permission is denied, please allow it in settings."
        case .videoCaptureDeviceNotAvailable:
            return "Video capture device is not available."
        case .qrScanningNotSupported:
            return "QR scanning is not supported."
        }
    }
}
