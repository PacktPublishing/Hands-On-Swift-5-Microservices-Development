import Vapor

struct CategoryResponse: Content {
    let id: Int
    let name: String
}

