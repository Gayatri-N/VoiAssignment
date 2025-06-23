//
//  NetworkServiceTests.swift
//  VoiAssignment
//
//  Created by Gayatri Nagarkar on 2025-06-23.
//

import XCTest
@testable import VoiAssignment

final class NetworkServiceTests: XCTestCase {
    var networkService: DefaultNetworkService!

    override func setUp() {
        super.setUp()

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)

        networkService = DefaultNetworkService(urlSession: session)
    }
    
    func test_performGet_given_initial_when_receivedSuccessfulResponse_then_returnsData() async throws {
        // Given
        let expectedData = "Test data".data(using: .utf8)!
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)

        let response = HTTPURLResponse(url: url, statusCode: 200,
                                       httpVersion: nil, headerFields: nil)!
        MockURLProtocol.mockResponse = (expectedData, response)

        // When
        let result = try await networkService.performGet(request)

        // Then
        XCTAssertEqual(result, expectedData)
    }
    
    func test_performGet_given_initial_when_receivedInvalidStatusCode_then_throwsError() async {
        // Given
        let data = Data()
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)

        let response = HTTPURLResponse(url: url, statusCode: 404,
                                       httpVersion: nil, headerFields: nil)!
        MockURLProtocol.mockResponse = (data, response)
        
        // When
        var resultError: Error?
        do {
            _ = try await networkService.performGet(request)
        } catch {
            resultError = error
        }

        // Then
        XCTAssertNotNil(resultError)
    }
    
    func test_performGet_given_initial_when_receivedNoResponse_then_throwsError() async {
        // Given
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)

        MockURLProtocol.mockResponse = nil

        // When
        var resultError: Error?
        do {
            _ = try await networkService.performGet(request)
        } catch {
            resultError = error
        }
        
        // Then
        XCTAssertNotNil(resultError)
    }
}

class MockURLProtocol: URLProtocol {
    static var mockResponse: (Data, HTTPURLResponse)?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let (data, response) = MockURLProtocol.mockResponse {
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            self.client?.urlProtocol(self, didLoad: data)
        } else {
            self.client?.urlProtocol(self, didFailWithError: NetworkServiceError.invalidResponse)
        }
        self.client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}
