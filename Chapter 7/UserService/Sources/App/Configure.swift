import Fluent
import FluentMySQLDriver
import Vapor
import JWT
import SendGrid

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
    
    guard let sendgridApiKey = Environment.get("SENDGRID_API_KEY") else {
               fatalError("No value was found at the given public key environment SENDGRID_API_KEY")
    }
    let sendgridClient = SendGridClient(client: app.client, apiKey: sendgridApiKey)
    
    app.migrations.add(CreateUser())
    app.migrations.add(CreateAddress())

    // register routes
    try routes(app, sendgridClient)
}
