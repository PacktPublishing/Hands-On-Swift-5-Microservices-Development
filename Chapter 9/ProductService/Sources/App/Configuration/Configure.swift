import JWTDataProvider
import Authentication
import FluentMySQL
import JWTVapor
import APIErrorMiddleware
import Vapor
import VaporRequestStorage

public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    
    try services.register(AuthenticationProvider())
    try services.register(FluentMySQLProvider())
    try services.register(StorageProvider())
    
    services.register(Router.self) { container -> EngineRouter in
        let router = EngineRouter.default()
        try routes(router, container)
        return router
    }
    
    var middlewares = MiddlewareConfig()
    middlewares.use(CORSMiddleware())
    middlewares.use(ErrorMiddleware.self)
    middlewares.use(APIErrorMiddleware(environment: env, specializations: [
        ModelNotFound()
    ]))
    services.register(middlewares)
    
    var databases = DatabasesConfig()
    let config = MySQLDatabaseConfig(
        hostname: Environment.get("DATABASE_HOSTNAME") ?? "localhost",
        port: Int(Environment.get("DATABASE_PORT") ?? "3306") ?? 3306,
        username: Environment.get("DATABASE_USER") ?? "root",
        password: Environment.get("DATABASE_PASSWORD") ?? "password",
        database: Environment.get("DATABASE_DB") ?? "service_products",
        transport: env.isRelease ? .cleartext : .unverifiedTLS
    )
    let database = MySQLDatabase(config: config)
    databases.add(database: database, as: .mysql)
    services.register(databases)
    
    var migrations = MigrationConfig()
    migrations.add(model: Category.self, database: .mysql)
    migrations.add(model: Product.self, database: .mysql)
    services.register(migrations)
    
    let jwt = JWTDataConfig()
    services.register(jwt)
    
}
