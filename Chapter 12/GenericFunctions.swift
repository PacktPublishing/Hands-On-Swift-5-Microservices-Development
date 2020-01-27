function saveModel<T:Model>(_ model: T, on app: Application) -> EventLoopFuture<T> {
    return model.save(on: app).transform(to: model)
}

let user = User()
return self.saveModel(user, on: app)
