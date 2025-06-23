//
//  AccessibilityIDs.swift
//  VoiAssignment
//
//  Created by Gayatri Nagarkar on 2025-06-23.
//

struct AccessibilityIDs {
    static let vehicleLookupView = VehicleLookupView()
    static let qrScanView = QRScanView()
    
    struct VehicleLookupView {
        let view = "vehicleLookupView"
        let infoLabel = "infoLabel"
        let startButton = "startButton"
    }
    
    struct QRScanView {
        let view = "qrScanView"
    }
}
