import Vapor
import JSON
import JWTMiddleware

extension JSON: JWTPayload {
    public func verify(using signer: JWTSigner) throws {
    }
}
