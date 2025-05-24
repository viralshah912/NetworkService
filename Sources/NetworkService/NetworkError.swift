//
//  NetworkError.swift
//  NetworkService
//
//  Created by VIRAL on 5/24/25.
//

import Foundation

public enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(Int)
    case unknown(Error)
}
