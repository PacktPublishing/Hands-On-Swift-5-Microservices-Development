import Fluent

struct CreateOrder: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("orders")
            .field("id", .int, .identifier(auto: true))
            .field("totalAmount", .int, .required)
            .field("paidAmount", .int, .required)
            .field("userId", .int, .required)
            .field("status", .int, .required)
            .field("firstname", .string, .required)
            .field("lastname", .string, .required)
            .field("street", .string, .required)
            .field("zip", .string, .required)
            .field("city", .string, .required)
            .field("createdAt", .datetime)
            .field("updatedAt", .datetime)
            .field("deletedAt", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("orders").delete()
    }
}
