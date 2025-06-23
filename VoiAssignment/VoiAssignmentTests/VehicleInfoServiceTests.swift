//
//  VehicleInfoServiceTests.swift
//  VoiAssignment
//
//  Created by Gayatri Nagarkar on 2025-06-23.
//

import XCTest
@testable import VoiAssignment

final class VehicleInfoServiceTests: XCTestCase {

    private var vehicleInfoService: VehicleInfoService!
    private var networkServiceMock: NetworkServiceMock!
    private let validUrl = URL(string: "https://ios-assignment.glitch.me/vehicle?qrcode=W9MB")!

    override func setUp() {
        networkServiceMock = NetworkServiceMock()
        vehicleInfoService = DefaultVehicleInfoService(networkService: networkServiceMock)
    }

    func test_getVehicleInfo_given_initial_when_receivedInvalidData_then_throwsError() async {
        // Given
        networkServiceMock.mockError = NetworkServiceError.invalidResponse

        // When
        var resultError: Error?
        do {
            _ = try await vehicleInfoService.getVehicleInfo(for: "W9MB")
        } catch {
            resultError = error
        }

        // Then
        XCTAssertNotNil(resultError)
    }

    func test_getVehicleInfo_given_initial_when_receivedValidData_then_returnsVehicleInfo() async {
        // Given
        networkServiceMock.mockData = "{\"name\":\"w9mb\",\"id\":\"fac39a25-7298-4226-952a-4a0a21759b9f\",\"category\":\"scooter\",\"price\":10,\"currency\":\"Kr\"}".data(using: .utf8)

        // When
        var info: VehicleInfo?
        do {
            info = try await vehicleInfoService.getVehicleInfo(for: "w9mb")
        } catch {
            XCTFail("Test failed with error: \(error)")
        }

        // Then
        XCTAssertEqual(info?.name, "w9mb")
    }

}

fileprivate final class NetworkServiceMock: NetworkService {

    var mockError: NetworkServiceError?
    var mockData: Data?

    func performGet(_ request: URLRequest) async throws -> Data {
        if let mockError {
            throw mockError
        }

        if let mockData {
            return mockData
        }

        return Data()
    }
}
