@testable import App
import Fluent
import XCTVapor

final class AppTests: XCTestCase {
    func testCreateTodo() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        // replace default database with in-memory db for testing
        app.databases.use(.sqlite(.memory), as: .test, isDefault: true)
        // run migrations automatically
        try app.autoMigrate().wait()

        
    }
}

extension DatabaseID {
    static var test: Self {
        .init(string: "test")
    }
}
