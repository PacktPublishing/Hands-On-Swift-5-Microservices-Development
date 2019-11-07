import Vapor
import JWTKit

/// A small middleware that is grabing what we need from the JWT token.
/// IMPORTANT: Does *not* perform a signature check. Should not be used for production.
public final class JWTMiddleware: Middleware {
    
    public init() {
    }
    /// Convenience function to decode base64.
    private func decodeBase64(_ str: String) -> String? {
        guard let data = Data(base64Encoded: str) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        
        guard let header:String = request.headers[.authorization].first else {
            return request.eventLoop.makeFailedFuture(Abort(.forbidden))
        }
        
        if header.count < 8 {
            return request.eventLoop.makeFailedFuture(Abort(.forbidden))
        }
        
        //let jwtSigner = JWTsi
        
        let index = header.index(header.startIndex, offsetBy: 7)
        
        if header.prefix(upTo: index) != "Bearer " {
            return request.eventLoop.makeFailedFuture(Abort(.badRequest))
        }
        
        let token = header.suffix(from: index)
        
        let parts = token.split(separator: ".")
        
        if parts.count != 3 {
            return request.eventLoop.makeFailedFuture(Abort(.badRequest))
        }
        let string = String(parts[1])
        let payloadJson = self.decodeBase64(string) ?? ""

        guard let payload = try? JSONDecoder().decode(JWTPayload.self, from: payloadJson.data(using: .utf8)!) else {
            return request.eventLoop.makeFailedFuture(Abort(.badRequest))
        }
        
        request.jwtPayload = payload
       
        return next.respond(to: request)
    }
}



/// Save the payload in the request
extension Request {
    private static var _jwtPayload = [String:JWTPayload]()
        
    var jwtPayload:JWTPayload? {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return Request._jwtPayload[tmpAddress]
        }
        set(newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            Request._jwtPayload[tmpAddress] = newValue
        }
    }
}

