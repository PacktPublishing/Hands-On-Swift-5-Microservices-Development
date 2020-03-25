import Vapor
import JWT

struct RefreshToken: JWTPayload {
    let id: Int
    let iat: TimeInterval
    let exp: TimeInterval
    
    init(user: User, expiration: TimeInterval = 24 * 60 * 60 * 30) {
        let now = Date().timeIntervalSince1970
        
        self.id = user.id ?? 0
        self.iat = now
        self.exp = now + expiration
    }
    
    func verify(using signer: JWTSigner) throws {
        let expiration = Date(timeIntervalSince1970: self.exp)
        try ExpirationClaim(value: expiration).verifyNotExpired()
    }
}
