import Foundation
import Fluent

final class Acronym: Model {
    static let schema = "acronyms"
    
    @ID(custom: "id")
    var id: Int?
    
    @Field(key: "short")
    var short: String
    
    @Field(key: "long")
    var long: String
    
    @Parent(key: "userID")
    var user: User
    
    @Siblings(through: AcronymCategoryPivot.self, from: \.$acronym, to: \.$category)
    var categories: [TILCategory]
    
    init() {}
    init(short: String, long: String, userID: UUID) {
        self.short = short
        self.long = long
        self.$user.id = userID
    }
}
