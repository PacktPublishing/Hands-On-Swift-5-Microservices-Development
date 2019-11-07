import Vapor

struct CategoryResponse: Content {
    let id: Int
    let name: String
}

struct ProductResponse: Content {
    let id: Int
    let name: String
    let description: String
    let price: Int
}
