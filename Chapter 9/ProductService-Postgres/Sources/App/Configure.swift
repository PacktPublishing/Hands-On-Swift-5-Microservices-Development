import Fluent
import FluentPostgresDriver
import Vapor
import JWT

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    guard let jwksString = Environment.process.JWKS else {
        fatalError("No value was found at the given public key environment 'JWKS'")
    }
    
    guard let psqlUrl = Environment.process.PSQL_CRED else {
        fatalError("No value was found at the given public key environment 'PSQL_CRED'")
    }
    
    guard let url = URL(string: psqlUrl) else {
        fatalError("Cannot parse: \(psqlUrl) correctly.")
    }
    
    app.databases.use(try .postgres(url: url), as: .psql)
    app.middleware.use(CORSMiddleware())
    app.middleware.use(ErrorMiddleware() { request, error in
        struct ErrorResponse: Content {
            var error: String
        }
        let data: Data?
        do {
            data = try JSONEncoder().encode(ErrorResponse(error: "\(error)"))
        }
        catch {
            data = "{\"error\":\"\(error)\"}".data(using: .utf8)
        }
        let res = Response(status: .internalServerError, body: Response.Body(data: data!))
        res.headers.replaceOrAdd(name: .contentType, value: "application/json")
        return res
    })
    
    try app.jwt.signers.use(jwksJSON: jwksString)
    
    app.migrations.add(CreateCategory())
    app.migrations.add(CreateProduct())

    // register routes
    try routes(app)
}
