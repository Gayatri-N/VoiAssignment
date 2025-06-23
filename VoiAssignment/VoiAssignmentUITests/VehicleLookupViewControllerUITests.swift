//
//  VehicleLookupViewControllerUITests.swift
//  VoiAssignment
//
//  Created by Gayatri Nagarkar on 2025-06-23.
//

import XCTest
import Combine

final class VehicleLookupViewControllerUITests: XCTestCase {
    
    private var app: XCUIApplication!
    
    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func test_vehicleLookupUIElements_given_initial_when_launch_then_elementsExist() {
        // Given: app is launched
        
        // Then: View is loaded
        let vehicleView = app.otherElements[AccessibilityIDs.vehicleLookupView.view]
        XCTAssertTrue(vehicleView.waitForExistence(timeout: 3), "Main view should be visible")
        
        let infoLabel = app.staticTexts[AccessibilityIDs.vehicleLookupView.infoLabel]
        XCTAssertTrue(infoLabel.exists, "Info label should exist")
        XCTAssertTrue(infoLabel.label.contains("Scan the QR code"), "Label text should match")
        
        let startButton = app.buttons[AccessibilityIDs.vehicleLookupView.startButton]
        XCTAssertTrue(startButton.exists, "Start button should exist")
        XCTAssertEqual(startButton.label, "Start", "Start button title should be 'Start'")
    }
    
    func test_qrScanViewVisible_given_appLaunch_when_startButtonTapped_then_opensQRScanView() {
        let startButton = app.buttons[AccessibilityIDs.vehicleLookupView.startButton]
        XCTAssertTrue(startButton.exists, "Start button must be visible")
        
        startButton.tap()
        
        addUIInterruptionMonitor(withDescription: "System Alerts") { alert in
            for button in alert.buttons.allElementsBoundByIndex where button.description == "Allow" {
                button.tap()
                return true
            }
            return false
        }
        
        // Wait for QR scanner sheet
        let qrScanView = app.otherElements[AccessibilityIDs.qrScanView.view]
        XCTAssertTrue(qrScanView.waitForExistence(timeout: 3), "QR Scan view should appear")
    }
}
