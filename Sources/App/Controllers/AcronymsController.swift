import Fluent
import Vapor

struct AcronymsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let acronymsRoutes = routes.grouped("api", "acronyms")
        acronymsRoutes.get(use: getAllHandler)
        acronymsRoutes.post(use: createHandler)
        acronymsRoutes.get(":acronymID", use: getHandler)
        acronymsRoutes.put(":acronymID", use: updateHandler)
        acronymsRoutes.delete(":acronymID", use: deleteHandler)
        acronymsRoutes.get("search", use: searchHandler)
        acronymsRoutes.get("first", use: getFirstHandler)
        acronymsRoutes.get("sorted", use: sortedHandler)
        acronymsRoutes.get(":acronymID", "user", use: getUserHandler)
        acronymsRoutes.post(":acronymID", "categories", ":categoryID", use: addCategoriesHandler)
        acronymsRoutes.get(":acronymID", "categories", use: getCategoriesHandler)
        acronymsRoutes.delete(":acronymID", "categories", ":categoryID", use: removeCategoriesHandler)
    }
    
    func getAllHandler(_ req: Request) async throws -> [Acronym.API] {
        try await Acronym.query(on: req.db).all().map { $0.toAPIModel() }
    }
    
    func createHandler(_ req: Request) async throws -> Response {
        let data = try req.content.decode(CreateAcronymData.self)
        let acronym = Acronym(short: data.short, long: data.long, userID: data.userID)
        try await acronym.save(on: req.db)
        return try await acronym.toAPIModel().encodeResponse(status: .created, for: req)
    }
    
    func getHandler(_ req: Request) async throws -> Acronym.API {
        guard let acronym = try await Acronym.find(req.parameters.get("acronymID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return acronym.toAPIModel()
    }
    
    func updateHandler(_ req: Request) async throws -> Acronym.API {
        guard let acronym = try await Acronym.find(req.parameters.get("acronymID"), on: req.db) else {
            throw Abort(.notFound)
        }
        let updatedAcronym = try req.content.decode(CreateAcronymData.self)
        acronym.short = updatedAcronym.short
        acronym.long = updatedAcronym.long
        acronym.$user.id = updatedAcronym.userID
        try await acronym.save(on: req.db)
        return acronym.toAPIModel()
    }
    
    func deleteHandler(_ req: Request) async throws -> HTTPStatus {
        guard let acronym = try await Acronym.find(req.parameters.get("acronymID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await acronym.delete(on: req.db)
        return .noContent
    }
    
    func searchHandler(_ req: Request) async throws -> [Acronym.API] {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return try await Acronym.query(on: req.db).group(.or) { or in
            or.filter(\.$short == searchTerm)
            or.filter(\.$long == searchTerm)
        }.all().map { $0.toAPIModel() }
    }
    
    func getFirstHandler(_ req: Request) async throws -> Acronym.API {
        guard let acronym = try await Acronym.query(on: req.db).first() else {
            throw Abort(.notFound)
        }
        return acronym.toAPIModel()
    }
    
    func sortedHandler(_ req: Request) async throws -> [Acronym.API] {
        try await Acronym.query(on: req.db).sort(\.$short, .ascending).all().map { $0.toAPIModel() }
    }
    
    func getUserHandler(_ req: Request) async throws -> User {
        guard let acronym = try await Acronym.find(req.parameters.get("acronymID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return try await acronym.$user.get(on: req.db)
    }
    
    func addCategoriesHandler(_ req: Request) async throws -> HTTPStatus {
        guard let acronym = try await Acronym.find(req.parameters.get("acronymID"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard let category = try await TILCategory.find(req.parameters.get("categoryID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await acronym.$categories.attach(category, on: req.db)
        return .created
    }
    
    func getCategoriesHandler(_ req: Request) async throws -> [TILCategory] {
        guard let acronym = try await Acronym.find(req.parameters.get("acronymID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return try await acronym.$categories.get(on: req.db)
    }
    
    func removeCategoriesHandler(_ req: Request) async throws -> HTTPStatus {
        guard let acronym = try await Acronym.find(req.parameters.get("acronymID"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard let category = try await TILCategory.find(req.parameters.get("categoryID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await acronym.$categories.detach(category, on: req.db)
        return .noContent
    }
}

struct CreateAcronymData: Content {
    let short: String
    let long: String
    let userID: UUID
}
