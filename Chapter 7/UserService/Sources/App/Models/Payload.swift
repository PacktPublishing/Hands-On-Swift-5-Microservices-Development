import Foundation
import Vapor
import JSON
import JWT
import JWTMiddleware

struct Payload: PermissionedUserPayload {
    let firstname: String?
    let lastname: String?
    let exp: TimeInterval
    let iat: TimeInterval
    let email: String
    let id: User.ID
    let status: Int = 0
    
    init(user: User, expiration: TimeInterval = 3600)throws {
        let now = Date().timeIntervalSince1970
        
        self.firstname = user.firstname
        self.lastname = user.lastname
        self.exp = now + expiration
        self.iat = now
        self.email = user.email
        self.id = try user.requireID()
    }
    
    func verify(using signer: JWTSigner) throws {
        let expiration = Date(timeIntervalSince1970: self.exp)
        try ExpirationClaim(value: expiration).verifyNotExpired()
    }
}
