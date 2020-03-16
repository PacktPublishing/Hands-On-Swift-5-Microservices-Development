import Fluent
import FluentMySQLDriver
import Vapor
import JWT

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    guard let jwksString = Environment.process.JWKS else { fatalError("No value was found at the given public key environment 'JWKS'")
    }
    
    guard let mysqlUrl = Environment.process.MYSQL_CRED else { fatalError("No value was found at the given public key environment 'MYSQL_CRED'")
           }
    guard let url = URL(string: mysqlUrl) else { fatalError("Cannot parse: \(mysqlUrl) correctly.")
    }
    app.databases.use(try .mysql(url: url), as: .mysql)
    
    app.middleware.use(CORSMiddleware())
    app.middleware.use(ErrorMiddleware() { request, error in
        // TODO: Make this much nicer.
        return Response(status: .internalServerError)
    })
    
    try app.jwt.signers.use(jwksJSON: jwksString)
    
    app.migrations.add(CreateCategory())
    app.migrations.add(CreateProduct())

    // register routes
    try routes(app)
}
