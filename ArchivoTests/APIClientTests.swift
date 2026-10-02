import XCTest
@testable import Archivo

final class APIClientTests: XCTestCase {
    func testProductionURLUsesTLS() {
        XCTAssertEqual(APIClient.baseURL.scheme, "https")
        XCTAssertEqual(APIClient.baseURL.host, "archivo.societext.workers.dev")
    }
}

