import XCTest
@testable import Archivo

final class ResponsiveLayoutTests: XCTestCase {
    func testReferenceCanvasDimensions() {
        XCTAssertEqual(ArchivoLayout.canvasWidth, 393, "Design canvas reference width should be 393 pt")
        XCTAssertEqual(ArchivoLayout.canvasHeight, 852, "Design canvas reference height should be 852 pt")
        XCTAssertEqual(ArchivoLayout.maxContentWidth, 430, "Max content width should be 430 pt")
        XCTAssertEqual(ArchivoLayout.minTouchTarget, 44, "Apple HIG minimum touch target should be 44 pt")
    }

    func testStartupStageProgress() {
        XCTAssertEqual(StartupStage.connecting.progress, 0.10)
        XCTAssertEqual(StartupStage.session.progress, 0.30)
        XCTAssertEqual(StartupStage.profile.progress, 0.55)
        XCTAssertEqual(StartupStage.data.progress, 0.75)
        XCTAssertEqual(StartupStage.ready.progress, 1.00)
    }

    func testMemoryModelDecoding() throws {
        let json = """
        {
            "id": "2fbbe177-b731-4dcb-b135-add43dfa1ad7",
            "title": "Atardecer en Valle de Bravo",
            "description": "Un viaje inolvidable",
            "visibility": "public",
            "symbol": "○",
            "entry_count": 5
        }
        """.data(using: .utf8)!

        let memory = try JSONDecoder().decode(Memory.self, from: json)
        XCTAssertEqual(memory.id, "2fbbe177-b731-4dcb-b135-add43dfa1ad7")
        XCTAssertEqual(memory.title, "Atardecer en Valle de Bravo")
        XCTAssertEqual(memory.displaySymbol, "○")
        XCTAssertEqual(memory.totalEntries, 5)
        XCTAssertEqual(memory.effectiveVisibility, "public")
    }
}
