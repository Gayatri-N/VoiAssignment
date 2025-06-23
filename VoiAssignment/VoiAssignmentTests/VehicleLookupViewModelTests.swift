//
//  VehicleLookupViewModelTests.swift
//  VoiAssignment
//
//  Created by Gayatri Nagarkar on 2025-06-23.
//

import XCTest
import Combine
@testable import VoiAssignment

final class VehicleLookupViewModelTests: XCTestCase {

    private var cancellables: Set<AnyCancellable> = []

    private let mockVehicleInfo = VehicleInfo(
        name: "w9mb",
        id: "fac39a25-7298-4226-952a-4a0a21759b9f",
        category: "scooter",
        price: 10,
        currency: "Kr"
    )

    func test_fetchVehicleInfo_given_initial_when_receiveSuccess_then_publishesVehicleInfo() async {
        // Given
        let service = MockVehicleInfoService(result: .success(mockVehicleInfo))
        let viewModel = DefaultVehicleLookupViewModel(vehicleInfoService: service)

        var receivedActions: [VehicleInfoViewModelAction] = []

        let expectation = expectation(description: "Should receive all expected actions")

        viewModel.actionPublisher
            .sink { action in
                receivedActions.append(action)
                if receivedActions.count == 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.fetchVehicleInfo(for: "w9mb")

        // Then
        await fulfillment(of: [expectation], timeout: 2)

        XCTAssertEqual(receivedActions.count, 3)
        XCTAssertEqual(receivedActions[0], .showActivity)
        XCTAssertEqual(receivedActions[1], .hideActivity)
        
        if case .showVehicleInfo(let info) = receivedActions[2] {
            XCTAssertEqual(info, mockVehicleInfo)
        } else {
            XCTFail("Expected showVehicleInfo action")
        }
    }

    func test_fetchVehicleInfo_given_initial_when_receiveFailure_then_publishesError() async {
        // Given
        let service = MockVehicleInfoService(result: .failure(NetworkServiceError.invalidResponse))
        let viewModel = DefaultVehicleLookupViewModel(vehicleInfoService: service)

        var receivedActions: [VehicleInfoViewModelAction] = []

        let expectation = expectation(description: "Should receive error action")

        viewModel.actionPublisher
            .sink { action in
                receivedActions.append(action)
                if receivedActions.count == 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.fetchVehicleInfo(for: "w9mb")

        // Then
        await fulfillment(of: [expectation], timeout: 2)

        XCTAssertEqual(receivedActions.first, .showActivity)

        guard case .showErrorAlert(let error) = receivedActions.last else {
            return XCTFail("Expected showErrorAlert action")
        }

        XCTAssertTrue(error is NetworkServiceError)
    }
}

final class MockVehicleInfoService: VehicleInfoService {
    var result: Result<VehicleInfo, Error>

    init(result: Result<VehicleInfo, Error>) {
        self.result = result
    }

    func getVehicleInfo(for code: String) async throws -> VehicleInfo {
        return try result.get()
    }
}
