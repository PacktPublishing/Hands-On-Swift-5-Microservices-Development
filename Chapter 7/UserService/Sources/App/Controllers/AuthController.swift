import JWTDataProvider
import JWTMiddleware
import CryptoSwift
import SendGrid
import Crypto
import Fluent
import Vapor
import JWT

final class AuthController: RouteCollection {
    private let jwtService: JWTService
    
    init(jwtService: JWTService) {
        self.jwtService = jwtService
    }
    
    func boot(router: Router) throws {
        let auth = router
        
        auth.post("accessToken", use: refreshAccessToken)
        
        let protected = auth.grouped(JWTAuthenticatableMiddleware<User>())
        protected.post("login", use: login)
        
        auth.post(User.self, at: "register", use: register)
    }
    
    func register(_ request: Request, _ user: User)throws -> Future<UserSuccessResponse> {
        try user.validate()
        
        let count = User.query(on: request).filter(\.email == user.email).count()
        return count.map(to: User.self) { count in
            guard count < 1 else { throw Abort(.badRequest, reason: "This email is already registered.") }
            return user
        }.flatMap(to: User.self) { (user) in
            user.password = try BCrypt.hash(user.password)
            
            return user.save(on: request)
        }.flatMap(to: User.self) { (user) in
            
            let client = try request.make(SendGridClient.self)
            
            let subject: String = "Your Registration"
            let body: String = "Please activate: "
            
            let name = [user.firstname, user.lastname].compactMap({ $0 }).joined(separator: " ")
            let from = EmailAddress(email: "info@domain.com", name: nil)
            let address = EmailAddress(email: user.email, name: name)
            let header = Personalization(to: [address], subject: subject)
            let email = SendGridEmail(personalizations: [header], from: from, subject: subject, content: [[
                "type": "text",
                "value": body
                ]])
            
            return try client.send([email], on: request).transform(to: user)
        }
        .response(on: request)
    }
    
    func refreshAccessToken(_ request: Request)throws -> Future<[String: String]> {
        let refreshToken = try request.content.syncGet(String.self, at: "refreshToken")
        let refreshJWT = try JWT<RefreshToken>(from: refreshToken, verifiedUsing: self.jwtService.signer)
        try refreshJWT.payload.verify(using: self.jwtService.signer)

        let userID = refreshJWT.payload.id
        let user = User.find(userID, on: request).unwrap(or: Abort(.badRequest, reason: "No user found with ID '\(userID)'."))
        
        return user.flatMap(to: (JSON, Payload).self) { user in
            
            let payload = try App.Payload(user: user)
            return try request.payloadData(self.jwtService.sign(payload), with: ["userId": "\(user.requireID())"], as: JSON.self).and(result: payload)
        }.map(to: [String: String].self) { payloadData in
            let payload = try payloadData.0.merge(payloadData.1.json())
            
            let token = try self.jwtService.sign(payload)
            return ["status": "success", "accessToken": token]
        }
    }
    
    func login(_ request: Request)throws -> Future<LoginResponse> {
        let user = try request.requireAuthenticated(User.self)
        let userPayload = try Payload(user: user)
        
        let remotePayload = try request.payloadData(
            self.jwtService.sign(userPayload),
            with: ["userId": "\(user.requireID())"],
            as: JSON.self
        )
        
        return remotePayload.map(to: LoginResponse.self) { remotePayload in
            let payload = try remotePayload.merge(userPayload.json())
            
            let accessToken = try self.jwtService.sign(payload)
            let refreshToken = try self.jwtService.sign(RefreshToken(user: user))
            
            let userResponse = UserResponse(user: user, addresses: nil)
            return LoginResponse(accessToken: accessToken, refreshToken: refreshToken, user: userResponse)
        }
    }
}
