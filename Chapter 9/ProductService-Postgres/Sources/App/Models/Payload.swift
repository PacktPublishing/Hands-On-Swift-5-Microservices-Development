import Foundation
import Vapor
import JWTKit

struct Payload: Content, JWTPayload {
    
    let firstname: String?
    let lastname: String?
    let exp: String
    let iat: String
    let email: String
    let id: Int
    
    func verify(using signer: JWTSigner) throws {
        let expiration = Date(timeIntervalSince1970: Double(self.exp)!)
        try ExpirationClaim(value: expiration).verifyNotExpired()
    }
}
