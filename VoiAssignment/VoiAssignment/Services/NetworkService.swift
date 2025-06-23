//
//  NetworkService.swift
//  VoiAssignment
//
//  Created by Gayatri Nagarkar on 2025-06-23.
//

import Foundation

protocol NetworkService {
    func performGet(_ request: URLRequest) async throws -> Data
}

final class DefaultNetworkService: NetworkService {

    private let urlSession: URLSession

    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    public func performGet(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await urlSession.data(for: request)
        guard
            let response = response as? HTTPURLResponse,
            response.statusCode == 200
        else {
            throw NetworkServiceError.invalidResponse
        }
        return data
    }
}

enum NetworkServiceError: Error {
    case invalidUrl(String)
    case invalidResponse
}

extension NetworkServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidUrl(let url):
            return "Invalid URL: \(url)"
        case .invalidResponse:
            return "This QR code is not valid."
        }
    }
}

