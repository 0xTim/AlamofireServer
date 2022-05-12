import Vapor
import Fluent

final class TILCategory: Model, Content {
    static let schema = "categories"
    
    @ID(custom: "id")
    var id: Int?
    
    @Field(key: "name")
    var name: String
    
    @Siblings(through: AcronymCategoryPivot.self, from: \.$category, to: \.$acronym)
    var acronyms: [Acronym]
    
    init() {}
    init(name: String) {
        self.name = name
    }
}
