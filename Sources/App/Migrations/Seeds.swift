import Foundation
import Fluent

struct AddDefaultUsers: AsyncMigration {
    func prepare(on database: Database) async throws {
        let user1 = User(name: "Admin", username: "admin")
        let user2 = User(name: "Tim", username: "timc")
        let user3 = User(name: "Alice", username: "alice")
        let user4 = User(name: "Bob", username: "bob")
        return try await [user1, user2, user3, user4].create(on: database)
    }
    
    func revert(on database: Database) async throws {}
}

struct AddDefaultAcronyms: AsyncMigration {
    func prepare(on database: Database) async throws {
        guard let user = try await User.query(on: database).first(), let userID = user.id else {
            return
        }
        let acronym1 = Acronym(short: "OMG", long: "Oh My God", userID: userID)
        let acronym2 = Acronym(short: "IKR", long: "I Know Right", userID: userID)
        let acronym3 = Acronym(short: "LOL", long: "Laugh Out Loud", userID: userID)
        let acronym4 = Acronym(short: "IRL", long: "In Real Life", userID: userID)
        return try await [acronym1, acronym2, acronym3, acronym4].create(on: database)
    }
    
    func revert(on database: Database) async throws {}
}

struct AddDefaultCategories: AsyncMigration {
    func prepare(on database: Database) async throws {
        let category1 = TILCategory(name: "Funny")
        let category2 = TILCategory(name: "Teenager")
        try await category1.save(on: database)
        try await category2.save(on: database)
        
        guard let acronym = try await Acronym.query(on: database).first() else {
            return
        }
        let pivot = try AcronymCategoryPivot(acronym, category1)
        try await pivot.create(on: database)
    }
    
    func revert(on database: Database) async throws {}
}
