import Fluent
import FluentMySQLDriver
import Vapor

func configure(_ app: Application) throws {
    
    
    guard
        let jwksString = Environment.process.JWKS
        else {
            fatalError("No value was found at the given public key environment 'JWKS'")
        }
    

    guard
        let urlString = Environment.process.MYSQL_CRED
    else {
        fatalError("No value was found at the given public key environment 'MYSQL_CRED'")
    }

    guard
        let url = URL(string: urlString)
    else {
        fatalError("Cannot parse: \(urlString) correctly.")
    }

    app.databases.use(try DatabaseDriverFactory.mysql(url: url), as: DatabaseID.mysql)
    app.middleware.use(CORSMiddleware())
//    app.middleware.use(ErrorMiddleware(())
    
    try app.jwt.signers.use(jwksJSON: jwksString)
    app.server.configuration.supportCompression = true
    
    app.migrations.add(CreateOrder())
    app.migrations.add(CreateOrderItem())
    app.migrations.add(CreateOrderPayment())
    
    try routes(app)

}
