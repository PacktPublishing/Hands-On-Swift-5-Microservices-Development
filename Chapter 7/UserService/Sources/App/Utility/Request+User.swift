import Vapor

extension Request {
    func user()throws -> User {
        let user = try self.requireAuthenticated(User.self)
        return user
    }
}
