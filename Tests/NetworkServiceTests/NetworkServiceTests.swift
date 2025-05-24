import Testing
import Foundation
@testable import NetworkService

struct NetworkServiceTests {
    
    struct TestResponse: Codable, Equatable {
        let message: String
    }
    
    @Test
    func testSuccessfulResponse() async throws {
        let mockSession = MockSession()
        let responseObj = TestResponse(message: "Success")
        mockSession.nextData = try JSONEncoder().encode(responseObj)
        
        let service = NetworkService(session: mockSession)
        
        let result: TestResponse = try await service.request(
            url: "https://example.com",
            method: .get,
            responseType: TestResponse.self
        )
        
        #expect(result == responseObj)
    }
    
    @Test
    func testServerError() async throws {
        let mockSession = MockSession()
        mockSession.nextResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )
        mockSession.nextData = Data()
        
        let service = NetworkService(session: mockSession)
        
        do {
            let _: TestResponse = try await service.request(
                url: "https://example.com",
                method: .get,
                responseType: TestResponse.self
            )
            #expect(Bool(false), "Expected server error but got success")
        } catch NetworkError.serverError(let code) {
            #expect(code == 500, "Expected 500 status code but got \(code)")
        } catch {
            #expect(Bool(false), "Unexpected error: \(error)")
        }
    }
    
    @Test
    func testInvalidURL() async throws {
        let service = NetworkService()
        
        do {
            let _: TestResponse = try await service.request(
                url: "invalid_url",
                method: .get,
                responseType: TestResponse.self
            )
            #expect(Bool(false), "Expected invalidURL error but got success")
        } catch NetworkError.invalidURL {
            // ✅ expected
        } catch {
            #expect(Bool(false), "Unexpected error: \(error)")
        }
    }
}
