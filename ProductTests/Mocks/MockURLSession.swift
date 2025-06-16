//
//  MockURLSession.swift
//  Product
//

@testable import Product
import XCTest

// MARK: - Mock Session

class MockURLSession: URLSessionProtocol {
    var responses: [URL: (Data?, URLResponse?, Error?)] = [:]

    func setResponse(for url: URL, data: Data?, response: URLResponse?, error: Error?) {
        responses[url] = (data, response, error)
    }

    func data(from url: URL) async throws -> (Data, URLResponse) {
        guard let (data, response, error) = responses[url] else {
            throw URLError(.fileDoesNotExist)
        }

        if let error = error {
            throw error
        }

        guard let data = data, let response = response else {
            throw URLError(.badServerResponse)
        }

        return (data, response)
    }
}
