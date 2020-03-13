import SendGrid
import Fluent
import Vapor
import JWTKit
import Crypto
import SimpleJWTMiddleware

final class AuthController: RouteCollection {
    var bodyCache:[String:String] = [:]
    let sendgridClient: SendGridClient
    
    init(_ sgc: SendGridClient) {
        self.sendgridClient = sgc
    }
    
    func boot(routes: RoutesBuilder) throws {
        routes.post("register", use: register)
        routes.post("login", use: login)
        routes.post("accessToken", use: refreshAccessToken)
        routes.post("newPassword", use: newPassword)
    }
    
    func register(_ request: Request) throws -> EventLoopFuture<UserSuccessResponse> {
        let user_ = try request.content.decode(NewUserInput.self)
        
        let user = try User(user_.email, user_.firstname, user_.lastname, user_.password)
        
        return User.query(on: request.db).filter(\.$email == user.email).all().flatMap { all -> EventLoopFuture<User> in
            if all.count > 0 {
                return request.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "This email is already registered."))
            }
            
            return user.save(on: request.db).transform(to: user)
        }.map { user in
            return UserSuccessResponse(user: UserResponse(user: user))
        }.flatMap { (userResponse) in
            let subject: String = "Your Registration"
            let body: String = "Welcome!"
            let name = [user.firstname, user.lastname].compactMap({ $0 }).joined(separator: " ")
            let from = EmailAddress(email: "info@domain.com", name: nil)
            let address = EmailAddress(email: user.email, name: name)
            let header = Personalization(to: [address], subject: subject)
            let email = SendGridEmail(personalizations: [header], from: from, subject: subject, content: [[
                "type": "text",
                "value": body
                ]])
            
            return self.sendgridClient.send([email], on: request.eventLoop).transform(to: userResponse)
        }
    }
    
    func newPassword(_ request: Request)throws -> EventLoopFuture<UserSuccessResponse> {
        let data = try request.content.decode(PasswordInput.self)
        let email:String = data.email
        
        var password:String = ""
        
        return User.query(on: request.db).filter(\.$email == email).first().flatMap { user -> EventLoopFuture<User> in
            let str:String = SHA512.hash(data: Date().description.data(using: .utf8)!).description
            let index = str.index(str.startIndex, offsetBy: 8)
            password = String(str[..<index])
            do {
                user!.password = try Bcrypt.hash(password)
            }
            catch {}
            
            return user!.save(on: request.db).transform(to: user!)
        }.flatMap { user -> EventLoopFuture<User> in
            
                let contentString = "Your new password is \(password)."
                    
                let name = [user.firstname, user.lastname].compactMap({ $0 }).joined(separator: " ")
                    let from = EmailAddress(email: "info@myparkplatz24.de", name: nil)
                let address = EmailAddress(email: user.email, name: name)
                let header = Personalization(to: [address], subject: "New Password")
                var c = [[
                    "type": "text/plain",
                    "value": contentString
                ]]
                c.append([
                        "type": "text/html", "value": contentString])
                
                let email = SendGridEmail(personalizations: [header], from: from, subject: "New Password", content: c)
                
                return self.sendgridClient.send([email], on: request.eventLoop).transform(to: user)
            
            
        }.flatMap { user in
            return user.save(on: request.db).transform(to: UserSuccessResponse(user: UserResponse(user: user)))
        }
    }
    
    /// A route handler that returns a new access and refresh token for the user.
    func refreshAccessToken(_ request: Request)throws -> EventLoopFuture<RefreshTokenResponse> {
        let data = try request.content.decode(RefreshTokenInput.self)
        let refreshToken = data.refreshToken
        let jwtPayload:RefreshToken = try request.application.jwt.signers.verify(refreshToken, as: RefreshToken.self)
        
        let userID = jwtPayload.id

        return User.query(on: request.db).filter(\.$id == userID).all().flatMap { users in
            if users.count == 0 {
                return request.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "No user found."))
            }
            let user: User = users.first!
            
            
            let payload = Payload(id: user.id!, email: user.email)
            
            var payloadString = ""
            do {
                payloadString = try request.application.jwt.signers.sign(payload)
            }
            catch {}
            
            return user.save(on: request.db).map { _ in
                return RefreshTokenResponse(accessToken: payloadString)
            }
        }
    }
    
    
    func login(_ request: Request)throws -> EventLoopFuture<LoginResponse> {
        let data = try request.content.decode(LoginInput.self)
        
        return User.query(on: request.db).filter(\.$email == data.email).all().flatMap { users in
            if users.count == 0 {
                return request.eventLoop.makeFailedFuture(Abort(.unauthorized))
            }
            let user = users.first!
            var check = false
            do {
                check = try Bcrypt.verify(data.password, created: user.password)
            }
            catch {}
            if check {
                let userPayload = Payload(id: user.id!, email: user.email)
               
                   do {
                        let accessToken = try request.application.jwt.signers.sign(userPayload)
                            let refreshPayload = RefreshToken(user: user)
                            let refreshToken = try request.application.jwt.signers.sign(refreshPayload)
                        let userResponse = UserResponse(user: user)
                        return user.save(on: request.db).transform(to: LoginResponse(accessToken: accessToken, refreshToken: refreshToken, user: userResponse))
                    }
                    catch {
                        return request.eventLoop.makeFailedFuture(Abort(.internalServerError))
                }
            }
            else {
                return request.eventLoop.makeFailedFuture(Abort(.unauthorized))
            }
        }
    }
}

