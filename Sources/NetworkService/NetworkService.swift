// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public protocol NetworkSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSession {}

public struct NetworkService {
    private let session: NetworkSession

    public init(session: NetworkSession = URLSession.shared) {
        self.session = session
    }

    public func request<T: Decodable>(
            url urlString: String,
            method: HTTPMethod,
            body: Encodable? = nil,
            responseType: T.Type
        ) async throws -> T {
            guard let url = URL(string: urlString) else {
                throw NetworkError.invalidURL
            }

            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            if let body = body {
                do {
                    request.httpBody = try JSONEncoder().encode(body)
                } catch {
                    throw NetworkError.decodingError
                }
            }

            do {
                let (data, response) = try await session.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }

                guard (200..<300).contains(httpResponse.statusCode) else {
                    throw NetworkError.serverError(httpResponse.statusCode)
                }

                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    return decoded
                } catch {
                    throw NetworkError.decodingError
                }
            } catch let error as NetworkError {
                throw error
            } catch let urlError as URLError {
                if urlError.code == .unsupportedURL {
                    throw NetworkError.invalidURL
                }
                throw NetworkError.unknown(urlError)
            } catch {
                throw NetworkError.unknown(error)
            }
        }
}
