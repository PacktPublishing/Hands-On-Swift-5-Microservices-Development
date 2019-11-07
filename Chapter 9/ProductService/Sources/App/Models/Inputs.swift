import Vapor

struct CategoryInput: Content {
    let name: String
}

struct ProductInput: Content {
    let name: String
    let description: String
    let price: Int
    let categoryId: Int
}
