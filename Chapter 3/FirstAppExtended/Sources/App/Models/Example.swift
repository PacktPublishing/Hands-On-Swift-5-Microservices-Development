import Fluent
import Vapor

final class Example: Model, Content {
    static let schema = "examples"
    
    @ID(key: "id")
    var id: Int?

    @Field(key: "title")
    var title: String

    init() { }

    init(id: Int? = nil, title: String) {
        self.id = id
        self.title = title
    }
}
