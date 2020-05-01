import Vapor

struct ProductResponse: Content {
    let id: Int
    let name: String
    let description: String
    let price: Int
}
