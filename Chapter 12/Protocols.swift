protocol HasEmail {
    var email: String { get set }
}
struct User: Model, HasEmail {
    var email: String
}

func checkEmailFor(model: HasEmail) {
    if model.email == "" {
        return false
    } else { 
        return true 
    }
}
