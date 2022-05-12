import Fluent

struct CreateAcronym: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("acronyms")
            .field("id", .int, .identifier(auto: true))
            .field("short", .string, .required)
            .field("long", .string, .required)
            .field("userID", .uuid, .required, .references("users", "id"))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("acronyms").delete()
    }
}
