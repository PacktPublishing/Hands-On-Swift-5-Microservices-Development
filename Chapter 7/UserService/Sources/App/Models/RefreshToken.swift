import Foundation
import Vapor
import JSON
import JWT
import JWTMiddleware

struct RefreshToken: IdentifiableJWTPayload {
    let id: User.ID
    let iat: TimeInterval
    let exp: TimeInterval
    
    init(user: User, expiration: TimeInterval = 24 * 60 * 60 * 30)throws {
        let now = Date().timeIntervalSince1970
        
        self.id = try user.requireID()
        self.iat = now
        self.exp = now + expiration
    }
    
    func verify(using signer: JWTSigner) throws {
        let expiration = Date(timeIntervalSince1970: self.exp)
        try ExpirationClaim(value: expiration).verifyNotExpired()
    }
}
