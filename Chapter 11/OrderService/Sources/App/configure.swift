import Fluent
import FluentMySQLDriver
import Vapor

// Called before your application initializes.
func configure(_ app: Application) throws {
    app.provider(FluentProvider())

    app.register(extension: MiddlewareConfiguration.self) { middlewares, app in
        middlewares.use(app.make(ErrorMiddleware.self))
    }
    
    let url = URL(string: Environment.get("MYSQL_URL") ?? "mysql://user:password@localhost:3306/db")!
    
    app.databases.mysql(configuration: MySQLConfiguration(url: url)!, on: app.make())
    
    app.register(Migrations.self) { c in
        var migrations = Migrations()
        migrations.add(CreateOrder(), to: .mysql)
        migrations.add(CreateOrderItem(), to: .mysql)
        migrations.add(CreateOrderPayment(), to: .mysql)
        return migrations
    }
    
    app.register(JWTMiddleware.self) { container in
        return JWTMiddleware()
    }
    
    try routes(app)
}
