import Fluent
import FluentMySQLDriver
import Vapor

// Called before your application initializes.
public func configure(_ app: Application) throws {
    // Serves files from `Public/` directory
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(CORSMiddleware())
    app.middleware.use(ErrorMiddleware())
    
    guard let urlString = Environment.process.MYSQL_CRED else {
            fatalError("No value was found at the given public key environment 'MYSQL_CRED'")
        }
    
    guard let jwksString = Environment.process.JWKS else {
        fatalError("No value was found at the given public key environment 'JWKS'")
    }
    
    app.databases.use(try DatabaseDriverFactory.mysql(url: url), as: DatabaseID.mysql)
    try app.jwt.signers.use(jwksJSON: jwksString)

    // Configure migrations
    app.migrations.add(CreateExample())
    
    try routes(app)
}
