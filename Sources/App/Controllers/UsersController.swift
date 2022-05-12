import Vapor

struct UsersController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let usersRoute = routes.grouped("api", "users")
        usersRoute.post(use: createHandler)
        usersRoute.get(use: getAllHandler)
        usersRoute.get(":userID", use: getHandler)
        usersRoute.get(":userID", "acronyms", use: getAcronymsHandler)
    }
    
    func createHandler(_ req: Request) async throws -> User {
        let user = try req.content.decode(User.self)
        try await user.save(on: req.db)
        return user
    }
    
    func getAllHandler(_ req: Request) async throws -> [User] {
        try await User.query(on: req.db).all()
    }
    
    func getHandler(_ req: Request) async throws -> User {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return user
    }
    
    func getAcronymsHandler(_ req: Request) async throws -> [Acronym.API] {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return try await user.$acronyms.get(on: req.db).map { $0.toAPIModel() }
    }
}
