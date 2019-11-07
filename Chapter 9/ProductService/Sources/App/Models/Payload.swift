import Foundation
import Vapor
import JSON
import JWT
import JWTMiddleware

struct Payload: IdentifiableJWTPayload {
    let firstname: String?
    let lastname: String?
    let exp: TimeInterval
    let iat: TimeInterval
    let email: String
    let id: Int
    let status: Int = 0
    
    func verify(using signer: JWTSigner) throws {
        let expiration = Date(timeIntervalSince1970: self.exp)
        try ExpirationClaim(value: expiration).verifyNotExpired()
        if self.status != 1 {
            throw JWTError(identifier: "exp", reason: "Expiration claim failed")
        }
    }
}
/*
import FluentMySQL
import Validation
import Crypto
import Vapor
import JWTMiddleware

final class User: MySQLModel, Migration, Validatable, BasicJWTAuthenticatable {
    static let entity: String = "users"
    
    var id: Int?
    var firstname: String?
    var lastname: String?
    var email: String
    var password: String
    var deletedAt: Date?
    var createdAt: Date?
    var updatedAt: Date?
    
    init(_ email: String) throws {
        self.email = email
        self.password = ""
    }
    
    convenience init(_ email: String, _ firstName: String? = nil, _ lastName: String? = nil, _ password: String)throws {
        try self.init(email)
        
        self.firstname = firstName
        self.lastname = lastName
        self.password = try BCryptDigest().hash(password)
    }

    func couples(on connection: DatabaseConnectable)throws -> QueryBuilder<CoupleUser.Database, CoupleUser> {
        return try CoupleUser.query(on: connection).filter(\.userId == self.requireID())
    }
    
    func response(on request: Request)throws -> Future<UserResponse> {
        return try self.couples(on: request).all().flatMap(to: UserResponse.self) { couples in
            var cr:[Future<CoupleUserResponse>] = []
            for c in couples {
                try cr.append(c.responseCouple(on: request))
            }
            return cr.flatten(on: request).map(to: UserResponse.self) { cr in
                return UserResponse(user: self, couples: cr)
            }
            
        }
    }
    
    static func validations() throws -> Validations<User> {
        var validations = Validations(User.self)
        try validations.add(\.password, .ascii && .count(6...))
        try validations.add(\.email, .email)
        return validations
    }
    
    static var usernameKey: WritableKeyPath<User, String> {
        return \.email
    }
    
    func accessToken(on request: Request) throws -> Future<Payload> {
        return Future.map(on: request) { try Payload(user: self) }
    }
    
    static var deletedAtKey: WritableKeyPath<User, Date?>? { return \.deletedAt }
    static var updatedAtKey: WritableKeyPath<User, Date?>? { return \.updatedAt }
    static var createdAtKey: WritableKeyPath<User, Date?>? { return \.createdAt }
}

*/
