import Foundation

struct User: Codable {
    var firstName: String
    var lastName: String
    var dateOfBirth: String // Store date as a string for simplicity
    var gender: String
    var bloodGroup: String
    var emergencyPhone: String
}

struct TimeSlot: Identifiable, Codable, Equatable {
    var id: String
    var startTime: Date
    var endTime: Date
    var isAvailable: Bool
    var isPremium: Bool

    // Initialize TimeSlot
    init(id: String, startTime: Date, endTime: Date, isAvailable: Bool, isPremium: Bool) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.isAvailable = isAvailable
        self.isPremium = isPremium
    }

    // Decoder initializer
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.startTime = try container.decode(Date.self, forKey: .startTime)
        self.endTime = try container.decode(Date.self, forKey: .endTime)
        self.isAvailable = try container.decode(Bool.self, forKey: .isAvailable)
        self.isPremium = try container.decode(Bool.self, forKey: .isPremium)
    }

    // Initialize from dictionary
    init?(from dictionary: [String: Any], id: String) {
        guard
            let startTimeTimestamp = dictionary["startTime"] as? TimeInterval,
            let endTimeTimestamp = dictionary["endTime"] as? TimeInterval,
            let isAvailable = dictionary["isAvailable"] as? Bool,
            let isPremium = dictionary["isPremium"] as? Bool
        else {
            return nil
        }

        self.id = id
        self.startTime = Date(timeIntervalSince1970: startTimeTimestamp)
        self.endTime = Date(timeIntervalSince1970: endTimeTimestamp)
        self.isAvailable = isAvailable
        self.isPremium = isPremium
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
    var timeSlots: [TimeSlot] // Array of TimeSlot objects
    var experience: Int

    var interval: String {
        return designation.interval
    }

    var name: String {
        return "\(firstName) \(lastName)"
    }

    var fees: String {
        return designation.fees
    }

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
        self.experience = experience
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
            let experience = dictionary["experience"] as? Int,
            let timeSlotDictionaries = dictionary["timeSlots"] as? [[String: Any]] // Ensure timeSlots are fetched correctly
        else {
            return nil
        }

        var timeSlots = [TimeSlot]()
         for (index, timeSlotDict) in timeSlotDictionaries.enumerated() {
             if let timeSlot = TimeSlot(from: timeSlotDict, id: "\(id)_slot_\(index)") {
                 timeSlots.append(timeSlot)
             }
         }

        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.dob = Date(timeIntervalSince1970: dobTimestamp)
        self.designation = designation
        self.titles = titles
        self.timeSlots = timeSlots
        self.experience = experience
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



