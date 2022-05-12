import Foundation
import Fluent

final class AcronymCategoryPivot: Model {
    static let schema = "acronym+categories"
    
    @ID
    var id: UUID?
    
    @Parent(key: "acronymID")
    var acronym: Acronym
    
    @Parent(key: "categoryID")
    var category: TILCategory
    
    init(){}
    init(_ acronym: Acronym, _ category: TILCategory) throws {
        self.$acronym.id = try acronym.requireID()
        self.$category.id = try category.requireID()
    }
}
