import Foundation

struct CurtainBlindLogItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var room: String
    var windowSize: String
    var fabricSource: String
    var createdAt: Date = Date()
}
