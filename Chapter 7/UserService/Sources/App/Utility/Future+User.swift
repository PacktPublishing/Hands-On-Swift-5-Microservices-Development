import Vapor

extension Future where T == User {
    func response(on request: Request) -> Future<UserSuccessResponse> {
        return self.flatMap(to: UserSuccessResponse.self) { try $0.response(on: request) }
    }
}
