import Foundation

struct User: Codable {
    var firstName: String
    var lastName: String
    var dateOfBirth: String // Store date as a string for simplicity
    var gender: String
    var bloodGroup: String
    var emergencyPhone: String
}
