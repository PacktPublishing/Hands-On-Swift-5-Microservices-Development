import Vapor
import Fluent

final class Product: Model {
    
    static let schema = "products"
    
    @ID(custom: "id")
    var id: Int?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "price")
    var price: Int
    
    @Field(key: "categoryId")
    var categoryId: Int
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deletedAt", on: .delete)
    var deletedAt: Date?
    
    init() {
    }
    
    init(name: String, description: String, price: Int, categoryId: Int) {
        self.name = name
        self.description = description
        self.price = price
        self.categoryId = categoryId
    }
}
