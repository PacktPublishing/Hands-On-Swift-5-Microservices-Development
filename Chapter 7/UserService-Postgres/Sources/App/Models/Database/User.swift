import Vapor
import Fluent

final class User: Model {
    
    static let schema = "users"
    
    init() {
    }
    
    @ID(key: "id")
    var id: Int?
    
    @Field(key: "firstname")
    var firstname: String?
    
    @Field(key: "lastname")
    var lastname: String?
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password")
    var password: String
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deletedAt", on: .delete)
    var deletedAt: Date?
    
    init(_ email: String, _ firstName: String? = nil, _ lastName: String? = nil, _ password: String)throws {
        self.email = email
        
        self.firstname = firstName
        self.lastname = lastName
        self.password = try BCryptDigest().hash(password)
    }
    
}
