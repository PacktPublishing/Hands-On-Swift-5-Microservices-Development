import Vapor
import JWTMiddleware

extension JWTError: AbortError {
    public var status: HTTPResponseStatus {
        switch self.identifier {
        case "exp": return .unauthorized
        default: return .internalServerError
        }
    }
}
