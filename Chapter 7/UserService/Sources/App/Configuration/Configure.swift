import JWTDataProvider
import Authentication
import FluentMySQL
import JWTVapor
import SendGrid
import APIErrorMiddleware
import Vapor
import VaporRequestStorage

public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    let jwtProvider = JWTProvider { n, d in
        guard let d = d else { throw Abort(.internalServerError, reason: "Could not find environment variable 'JWT_SECRET'", identifier: "missingEnvVar") }
        
        let headers = JWTHeader(alg: "RS256", crit: ["exp", "aud"], kid: "user_manager_kid")
        return try RSAService(n: n, e: "AQAB", d: d, header: headers)
    }
    
    try services.register(AuthenticationProvider())
    try services.register(FluentMySQLProvider())
    try services.register(SendGridProvider())
    try services.register(StorageProvider())
    try services.register(jwtProvider)
    
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
        database: Environment.get("DATABASE_DB") ?? "service_users",
        transport: env.isRelease ? .cleartext : .unverifiedTLS
    )
    let database = MySQLDatabase(config: config)
    databases.add(database: database, as: .mysql)
    services.register(databases)
    
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .mysql)
    migrations.add(model: Address.self, database: .mysql)
    services.register(migrations)
    
    let jwt = JWTDataConfig()
    services.register(jwt)
    
    let sendgridKey = Environment.get("SENDGRID_API_KEY") ?? "Create Environemnt Variable"
    services.register(SendGridConfig(apiKey: sendgridKey))
    
}
