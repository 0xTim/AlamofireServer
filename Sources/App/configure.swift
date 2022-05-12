import Fluent
import FluentSQLiteDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    
    app.migrations.add(CreateUser())
    app.migrations.add(CreateAcronym())
    app.migrations.add(CreateCategory())
    app.migrations.add(CreateAcronymCategoryPivot())
    app.migrations.add(AddDefaultUsers())
    app.migrations.add(AddDefaultAcronyms())
    app.migrations.add(AddDefaultCategories())
    
    // register routes
    try routes(app)
    
    try app.autoMigrate().wait()
    
    app.http.server.configuration.hostname = "0.0.0.0"
}
