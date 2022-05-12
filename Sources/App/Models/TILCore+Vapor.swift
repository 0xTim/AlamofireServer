import Vapor

extension Acronym {
    struct API: Content {
        let id: Int?
        let short: String
        let long: String
        let userID: UUID
    }
    
    func toAPIModel() -> API {
        API(id: self.id, short: self.short, long: self.long, userID: self.$user.id)
    }
}
