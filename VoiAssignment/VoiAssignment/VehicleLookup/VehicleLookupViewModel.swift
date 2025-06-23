//
//  VehicleLookupViewModel.swift
//  VoiAssignment
//
//  Created by Gayatri Nagarkar on 2025-06-23.
//

import Foundation
import Combine

protocol VehicleLookupViewModel {
    var actionPublisher: PassthroughSubject<VehicleInfoViewModelAction, Never> { get }
    func fetchVehicleInfo(for code: String)
}

final class DefaultVehicleLookupViewModel: VehicleLookupViewModel {

    let actionPublisher = PassthroughSubject<VehicleInfoViewModelAction, Never>()
    
    private let vehicleInfoService: VehicleInfoService

    // MARK: - Initialization methods
    init(vehicleInfoService: VehicleInfoService = DefaultVehicleInfoService()) {
        self.vehicleInfoService = vehicleInfoService
    }

    // MARK: - Public methods
    public func fetchVehicleInfo(for code: String) {
        Task { [weak self] in
            guard let self else { return }

            actionPublisher.send(.showActivity)
            do {
                let data = try await vehicleInfoService.getVehicleInfo(for: code)
                handle(data)
            } catch {
                handle(error)
            }
        }
    }

    // MARK: - Private methods
    private func handle(_ data: VehicleInfo) {
        actionPublisher.send(.hideActivity)
        actionPublisher.send(.showVehicleInfo(vehicleInfo: data))
    }

    private func handle(_ error: Error) {
        actionPublisher.send(.hideActivity)
        actionPublisher.send(.showErrorAlert(error))
    }
}

// MARK: - VehicleInfoViewModelAction -
enum VehicleInfoViewModelAction: Equatable {
    case showActivity
    case hideActivity
    case showVehicleInfo(vehicleInfo: VehicleInfo)
    case showErrorAlert(Error)
    
    static func == (lhs: VehicleInfoViewModelAction, rhs: VehicleInfoViewModelAction) -> Bool {
        switch (lhs, rhs) {
        case (.showActivity, .showActivity),
            (.hideActivity, .hideActivity):
            return true
            
        case let (.showVehicleInfo(lhsInfo), .showVehicleInfo(rhsInfo)):
            return lhsInfo == rhsInfo
            
        case (.showErrorAlert, .showErrorAlert):
            return true
            
        default:
            return false
        }
    }
}
