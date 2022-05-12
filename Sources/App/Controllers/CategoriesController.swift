import Vapor

struct CategoriesController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let categoriesRoute = routes.grouped("api", "categories")
        categoriesRoute.post(use: createHandler)
        categoriesRoute.get(use: getAllHandler)
        categoriesRoute.get(":categoryID", use: getHandler)
        categoriesRoute.get(":categoryID", "acronyms", use: getAcronymsHandler)
    }
    
    func createHandler(_ req: Request) async throws -> TILCategory {
        let category = try req.content.decode(TILCategory.self)
        try await category.save(on: req.db)
        return category
    }
    
    func getAllHandler(_ req: Request) async throws -> [TILCategory] {
        try await TILCategory.query(on: req.db).all()
    }
    
    func getHandler(_ req: Request) async throws -> TILCategory {
        guard let category = try await TILCategory.find(req.parameters.get("categoryID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return category
    }
    
    func getAcronymsHandler(_ req: Request) async throws -> [Acronym.API] {
        guard let category = try await TILCategory.find(req.parameters.get("categoryID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return try await category.$acronyms.get(on: req.db).map { $0.toAPIModel() }
    }
}
