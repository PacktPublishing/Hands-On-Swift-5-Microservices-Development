func checkEmail(email: String) -> Bool {
    // ...
    return true
}
var testString = "test@test.com"
if checkEmail(email: testString) {
    print("yep")
}


// Cleaner:

extension String {
    func checkEmail() -> Bool {
        // ...
        return true
    }
}
var testString = "test@test.com"
if testString.checkEmail() {
    print("yep")
}
