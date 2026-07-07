import Foundation

struct ProjectEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var room: String
    var material: String
    var lengthFeet: String
    var cost: String
    var createdAt: Date

    init(id: UUID = UUID(), room: String, material: String, lengthFeet: String, cost: String = "", createdAt: Date = Date()) {
        self.id = id
        self.room = room
        self.material = material
        self.lengthFeet = lengthFeet
        self.cost = cost
        self.createdAt = createdAt
    }
}
