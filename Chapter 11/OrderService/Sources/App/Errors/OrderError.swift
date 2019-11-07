import Vapor

enum OrderError: Error {
    case totalsNotMatching
    case paymentMissing
    case overpayment
    case orderNotFound
}
