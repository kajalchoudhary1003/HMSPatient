import Foundation

struct User: Codable {
    var firstName: String
    var lastName: String
    var dateOfBirth: String // Store date as a string for simplicity
    var gender: String
    var bloodGroup: String
    var emergencyPhone: String
}

struct TimeSlot: Codable, Identifiable, Equatable {
    var id: String = UUID().uuidString
    var startTime: Date
    var endTime: Date
    var isAvailable: Bool = true
    var isPremium: Bool = false
    
    static func == (lhs: TimeSlot, rhs: TimeSlot) -> Bool {
        return lhs.id == rhs.id && lhs.startTime == rhs.startTime && lhs.endTime == rhs.endTime
    }
    var time: String {
        return "\(startTime) \(endTime)"
    }

    func toDictionary() -> [String: Any] {
        return [
            "startTime": startTime.timeIntervalSince1970,
            "endTime": endTime.timeIntervalSince1970
        ]
    }
    
    init?(from dictionary: [String: Any]) {
        guard let startTime = dictionary["startTime"] as? TimeInterval,
              let endTime = dictionary["endTime"] as? TimeInterval else {
            return nil
        }
        self.startTime = Date(timeIntervalSince1970: startTime)
        self.endTime = Date(timeIntervalSince1970: endTime)
    }
}


struct Appointment: Hashable, Codable {
    var id: String?
    var patientID: String?
    var doctorID: String?
    var date: Date
    var timeSlotID: String
    
    enum CodingKeys: String, CodingKey {
        case id, patientID, doctorID, date, timeSlotID
    }
    
    init(patientID: String, doctorID: String, date: Date, timeSlotID: String, id: String? = nil) {
        self.id = id
        self.patientID = patientID
        self.doctorID = doctorID
        self.date = date
        self.timeSlotID = timeSlotID
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.patientID = try container.decode(String.self, forKey: .patientID)
        self.doctorID = try container.decode(String.self, forKey: .doctorID)
        self.date = try container.decode(Date.self, forKey: .date)
        self.timeSlotID = try container.decode(String.self, forKey: .timeSlotID)
    }
}

struct Doctor: Codable, Identifiable, Equatable {
    var id: String
    var firstName: String
    var lastName: String
    var email: String
    var phone: String
    var dob: Date
    var designation: DoctorDesignation
    var titles: String // Assuming this represents years of experience or titles
    var timeSlots: [TimeSlot]

    var interval: String {
        return designation.interval
    }
    var name: String {
        return "\(firstName) \(lastName)"
    }
    var fees: String {
        return designation.fees
    }
    var experience: Int

    init(id: String, firstName: String, lastName: String, email: String, phone: String, dob: Date, designation: DoctorDesignation, titles: String, timeSlots: [TimeSlot], experience: Int) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.dob = dob
        self.designation = designation
        self.titles = titles
        self.timeSlots = timeSlots
        self.experience = experience // Initialize experience property
    }

    init?(from dictionary: [String: Any], id: String) {
        guard
            let firstName = dictionary["firstName"] as? String,
            let lastName = dictionary["lastName"] as? String,
            let email = dictionary["email"] as? String,
            let phone = dictionary["phone"] as? String,
            let dobTimestamp = dictionary["dob"] as? TimeInterval,
            let designationRaw = dictionary["designation"] as? String,
            let designation = DoctorDesignation(rawValue: designationRaw),
            let titles = dictionary["titles"] as? String,
            let timeSlotDictionaries = dictionary["timeSlots"] as? [[String: Any]],
            let experience = dictionary["experience"] as? Int // Parse experience from dictionary
        else {
            return nil
        }

        let timeSlots = timeSlotDictionaries.compactMap { TimeSlot(from: $0) }

        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.dob = Date(timeIntervalSince1970: dobTimestamp)
        self.designation = designation
        self.titles = titles
        self.timeSlots = timeSlots
        self.experience = experience // Assign experience to the property
    }

    static func == (lhs: Doctor, rhs: Doctor) -> Bool {
        return lhs.id == rhs.id
    }
}

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
        case .generalPractitioner: return "30"
        case .pediatrician: return "10"
        case .cardiologist: return "15"
        case .dermatologist: return "20"
        }
    }

    static var withSelectOption: [DoctorDesignation?] {
        return [nil] + DoctorDesignation.allCases
    }
}



