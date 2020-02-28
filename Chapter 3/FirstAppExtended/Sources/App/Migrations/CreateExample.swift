import Fluent

struct CreateExample: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("examples")
            .field("id", .int, .identifier(auto: true))
            .field("title", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("examples").delete()
    }
}
