import Vapor
let app = try Application()

app.get("hello") { req in
    return "Hello, world."
}

try app.run()
