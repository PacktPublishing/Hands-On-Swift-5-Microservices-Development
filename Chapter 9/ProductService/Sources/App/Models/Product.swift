import FluentMySQL
import Vapor

final class Product: Content, MySQLModel, Migration, Parameter {
    static let entity: String = "products"
    
    var id: Int?
    var name: String
    var description: String
    var price: Int
    var categoryId: Category.ID
    
    init(name: String, description: String, price: Int, categoryId: Int) {
        self.name = name
        self.description = description
        self.price = price
        self.categoryId = categoryId
    }
    
    static func prepare(on connection: MySQLDatabase.Connection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.categoryId, to: \Category.id)
        }
    }
}
