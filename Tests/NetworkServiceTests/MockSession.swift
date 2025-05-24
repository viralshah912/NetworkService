//
//  MockSession.swift
//  NetworkService
//
//  Created by VIRAL on 5/24/25.
//

import Foundation
@testable import NetworkService

final class MockSession: NetworkSession {
    var nextData: Data?
    var nextResponse: URLResponse?
    var nextError: Error?
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = nextError {
            throw error
        }
        
        return (
            nextData ?? Data(),
            nextResponse ?? HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
        )
    }
}
