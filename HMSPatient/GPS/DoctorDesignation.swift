import Foundation
import FirebaseFirestoreSwift

// Enumeration for Doctor's Designation with associated properties
enum DoctorDesignation: String, Codable, CaseIterable {
    case generalPractitioner = "General Practitioner"
    case pediatrician = "Pediatrician"
    case cardiologist = "Cardiologist"
    case dermatologist = "Dermatologist"

    // Returns the title of the designation
    var title: String {
        return self.rawValue
    }

    // Returns the fees associated with the designation
    var fees: String {
        switch self {
        case .generalPractitioner: return "$100"
        case .pediatrician: return "$120"
        case .cardiologist: return "$150"
        case .dermatologist: return "$130"
        }
    }

    // Returns the consultation interval associated with the designation
    var interval: String {
        switch self {
        case .generalPractitioner: return "9:00 AM - 11:00 AM"
        case .pediatrician: return "11:00 AM - 1:00 PM"
        case .cardiologist: return "2:00 PM - 4:00 PM"
        case .dermatologist: return "4:00 PM - 6:00 PM"
        }
    }
}

// Struct to represent a Doctor
struct Doctor: Codable, Identifiable, Equatable {
    @DocumentID var id: String?
    var firstName: String
    var lastName: String
    var email: String
    var phone: String
    var starts: Date
    var ends: Date
    var dob: Date
    var designation: DoctorDesignation
    var titles: String
    
    // Computed property to return the consultation interval based on the designation
    var interval: String {
        return designation.interval
    }
    
    // Computed property to return the fees based on the designation
    var fees: String {
        return designation.fees
    }

    init(id: String? = nil, firstName: String, lastName: String, email: String, phone: String, starts: Date, ends: Date, dob: Date, designation: DoctorDesignation, titles: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.starts = starts
        self.ends = ends
        self.dob = dob
        self.designation = designation
        self.titles = titles
    }
    
    // Equatable conformance to compare two Doctor instances
    static func == (lhs: Doctor, rhs: Doctor) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Convert Doctor object to dictionary for Firebase
    func toDictionary() -> [String: Any] {
        return [
            "id": id ?? UUID().uuidString,
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "phone": phone,
            "starts": starts.timeIntervalSince1970,
            "ends": ends.timeIntervalSince1970,
            "dob": dob.timeIntervalSince1970,
            "designation": designation.rawValue,
            "titles": titles
        ]
    }
    
    // Initialize Doctor object from dictionary
    init?(from dictionary: [String: Any], id: String) {
        guard let firstName = dictionary["firstName"] as? String,
              let lastName = dictionary["lastName"] as? String,
              let email = dictionary["email"] as? String,
              let phone = dictionary["phone"] as? String,
              let starts = dictionary["starts"] as? TimeInterval,
              let ends = dictionary["ends"] as? TimeInterval,
              let dob = dictionary["dob"] as? TimeInterval,
              let designationRaw = dictionary["designation"] as? String,
              let designation = DoctorDesignation(rawValue: designationRaw),
              let titles = dictionary["titles"] as? String else {
            return nil
        }
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.starts = Date(timeIntervalSince1970: starts)
        self.ends = Date(timeIntervalSince1970: ends)
        self.dob = Date(timeIntervalSince1970: dob)
        self.designation = designation
        self.titles = titles
        self.id = id
    }
}
