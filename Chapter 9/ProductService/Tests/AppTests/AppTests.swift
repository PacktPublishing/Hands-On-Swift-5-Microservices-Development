import XCTest
import Vapor
@testable import App

public class AppTests: XCTestCase {
    func testBCrypt() {
        do {
            let hash = try Bcrypt.hash("password")
            print(hash)
        } catch let error {
            print(error)
        }
    }
}
