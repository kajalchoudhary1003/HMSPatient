import Foundation

struct User: Codable {
    var firstName: String
    var lastName: String
    var dateOfBirth: String // Store date as a string for simplicity
    var gender: String
    var bloodGroup: String
    var emergencyPhone: String
}

struct TimeSlot: Identifiable, Equatable {
    let id = UUID()
    var time: String
    var isAvailable: Bool
    var isPremium: Bool  // Added isPremium flag

    static func == (lhs: TimeSlot, rhs: TimeSlot) -> Bool {
        return lhs.time == rhs.time && lhs.isAvailable == rhs.isAvailable && lhs.id == rhs.id
    }
}

struct Doctor: Identifiable {
    let id = UUID()
    var name: String
    var experience: Int
    var age: Int
    var fees: Int
    var availableTimeSlots: [TimeSlot]
}
