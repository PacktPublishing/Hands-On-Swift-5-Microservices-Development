import Fluent

struct CreateAddress: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("addresses")
            .field("id", .int, .identifier(auto: true))
            .field("userId", .int, .references("users", "id"))
            .field("street", .string, .required)
            .field("zip", .string, .required)
            .field("city", .string, .required)
            .field("createdAt", .datetime)
            .field("updatedAt", .datetime)
            .field("deletedAt", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("addresses").delete()
    }
}
