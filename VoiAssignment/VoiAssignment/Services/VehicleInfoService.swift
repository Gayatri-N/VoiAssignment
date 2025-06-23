//
//  VehicleInfoService.swift
//  VoiAssignment
//
//  Created by Gayatri Nagarkar on 2025-06-23.
//

import Foundation

protocol VehicleInfoService {
    func getVehicleInfo(for code: String) async throws -> VehicleInfo
}

final class DefaultVehicleInfoService: VehicleInfoService {

    private let networkService: NetworkService
    private let baseUrl = "https://ios-assignment.glitch.me/vehicle?qrcode="
    
    init(networkService: NetworkService = DefaultNetworkService()) {
        self.networkService = networkService
    }

    public func getVehicleInfo(for code: String) async throws -> VehicleInfo {
        guard let url = URL(string: "\(baseUrl)\(code)") else {
            throw NetworkServiceError.invalidUrl("\(baseUrl)\(code)")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let data = try await networkService.performGet(request)
        let response = try JSONDecoder().decode(VehicleInfoResponse.self, from: data)
        let vehicleInfo = VehicleInfo(with: response)
        return vehicleInfo
    }
}
