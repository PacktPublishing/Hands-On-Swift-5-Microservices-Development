import Fluent


struct CreateProduct: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("products")
            .field("id", .int, .identifier(auto: true))
            .field("name", .string, .required)
            .field("description", .string, .required)
            .field("categoryId", .int, .required)
            .field("price", .int, .required)
            .field("createdAt", .datetime)
            .field("updatedAt", .datetime)
            .field("deletedAt", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("products").delete()
    }
}
