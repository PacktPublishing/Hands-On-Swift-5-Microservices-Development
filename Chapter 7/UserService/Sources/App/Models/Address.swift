import FluentMySQL
import Vapor

final class Address: Content, MySQLModel, Migration, Parameter {
    static let entity: String = "addresses"
    
    var id: Int?
    var street: String
    var city: String
    var zip: String
    let userId: Int
    
    init(street: String, city: String, zip: String, userId: Int) {
        self.street = street
        self.city = city
        self.zip = zip
        self.userId = userId
    }
    
    static func prepare(on connection: MySQLDatabase.Connection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userId, to: \User.id)
        }
    }
}
