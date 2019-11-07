import FluentMySQL
import Vapor

final class Category: Content, MySQLModel, Migration, Parameter {
    static let entity: String = "categories"
    
    var id: Int?
    var name: String
    
    init(name: String) {
        self.name = name
    }
}
