import Fluent
import Vapor

struct NewController {
    func newFunction(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return req.eventLoop.makeSucceededFuture(.ok)
    }
}
