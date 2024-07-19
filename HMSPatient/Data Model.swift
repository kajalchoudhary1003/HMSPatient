import Foundation

struct User: Codable {
    var firstName: String
    var lastName: String
    var dateOfBirth: String // Store date as a string for simplicity
    var gender: String
    var bloodGroup: String
    var emergencyPhone: String
}

struct TimeSlot: Codable,Hashable, Identifiable, Equatable {
    var id: String = UUID().uuidString
    var startTime: Date
    var endTime: Date
    var isAvailable: Bool = true
    var isPremium: Bool = false
    
    // Correct the time property to format the start and end times
    var time: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
    
    // Initializer to create TimeSlot from time intervals
    init(startTime: Date, endTime: Date, isPremium: Bool = false, isAvailable: Bool = true) {
        self.startTime = startTime
        self.endTime = endTime
        self.isPremium = isPremium
        self.isAvailable = isAvailable
    }
    
    // Initializer to create TimeSlot from dictionary
    init?(from dictionary: [String: Any]) {
        guard let startTimeInterval = dictionary["startTime"] as? TimeInterval,
              let endTimeInterval = dictionary["endTime"] as? TimeInterval else {
            return nil
        }
        self.startTime = Date(timeIntervalSince1970: startTimeInterval)
        self.endTime = Date(timeIntervalSince1970: endTimeInterval)
        self.isAvailable = dictionary["isAvailable"] as? Bool ?? true
        self.isPremium = dictionary["isPremium"] as? Bool ?? false
    }
    
    // Method to convert TimeSlot to dictionary
    func toDictionary() -> [String: Any] {
        return [
            "startTime": startTime.timeIntervalSince1970,
            "endTime": endTime.timeIntervalSince1970,
            "isAvailable": isAvailable,
            "isPremium": isPremium
        ]
    }
    
    // Equatable implementation
    static func == (lhs: TimeSlot, rhs: TimeSlot) -> Bool {
        return lhs.id == rhs.id && lhs.startTime == rhs.startTime && lhs.endTime == rhs.endTime
    }
}

struct Appointment: Hashable, Codable {
    let id: String
    var patientID: String?
    let doctorID: String
    let date: Date
    var shortDescription: String?
    var prescription: String?
    var timeSlot: TimeSlot
    var isCompleted: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, patientID, doctorID, date, shortDescription, prescription, timeSlot, isCompleted
    }

    init(id: String, patientID: String? = nil, doctorID: String, date: Date, shortDescription: String? = nil, prescription: String? = nil, timeSlot: TimeSlot, isCompleted: Bool = false) {
        self.id = id
        self.patientID = patientID
        self.doctorID = doctorID
        self.date = date
        self.shortDescription = shortDescription
        self.prescription = prescription
        self.timeSlot = timeSlot
        self.isCompleted = isCompleted
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.patientID = try container.decodeIfPresent(String.self, forKey: .patientID)
        self.doctorID = try container.decode(String.self, forKey: .doctorID)
        self.date = try container.decode(Date.self, forKey: .date)
        self.shortDescription = try container.decodeIfPresent(String.self, forKey: .shortDescription)
        self.prescription = try container.decodeIfPresent(String.self, forKey: .prescription)
        self.timeSlot = try container.decode(TimeSlot.self, forKey: .timeSlot)
        self.isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(patientID, forKey: .patientID)
        try container.encode(doctorID, forKey: .doctorID)
        try container.encode(date, forKey: .date)
        try container.encodeIfPresent(shortDescription, forKey: .shortDescription)
        try container.encodeIfPresent(prescription, forKey: .prescription)
        try container.encode(timeSlot, forKey: .timeSlot)
        try container.encode(isCompleted, forKey: .isCompleted)
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
    var titles: String
    var experience: Int
    var starts: Date
    var ends: Date
    var interval: String {
        return designation.interval
    }
    var name: String {
        return "\(firstName) \(lastName)"
    }
    var fees: String {
        return designation.fees
    }

    init(id: String, firstName: String, lastName: String, email: String, phone: String, dob: Date, designation: DoctorDesignation, titles: String, experience: Int, starts: Date, ends: Date) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.dob = dob
        self.designation = designation
        self.titles = titles
        self.experience = experience
        self.starts = starts
        self.ends = ends
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
            let starts = dictionary["starts"] as? TimeInterval,
            let ends = dictionary["ends"] as? TimeInterval
        else {
            print("Failed to parse Doctor data")
            return nil
        }

        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.dob = Date(timeIntervalSince1970: dobTimestamp)
        self.designation = designation
        self.titles = titles
        self.experience = dictionary["experience"] as? Int ?? 0
        self.starts = Date(timeIntervalSince1970: starts)
        self.ends = Date(timeIntervalSince1970: ends)
    }

    static func == (lhs: Doctor, rhs: Doctor) -> Bool {
        return lhs.id == rhs.id
    }
    static var example: Doctor {
            return Doctor(
                id: "1",
                firstName: "John",
                lastName: "Doe",
                email: "john.doe@example.com",
                phone: "123-456-7890",
                dob: Date(timeIntervalSince1970: 567648000), // Arbitrary date
                designation: .cardiologist,
                titles: "MD",
                experience: 15,
                starts: Date(),
                ends: Date().addingTimeInterval(3600)
            )
        }
}

enum DoctorDesignation: String, Codable, CaseIterable {
        case generalPractitioner = "General Practitioner"
        case pediatrician = "Pediatrician"
        case cardiologist = "Cardiologist"
        case dermatologist = "Dermatologist"
        case neurologist = "Neurologist"
        

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
            case .neurologist: return "$160"
            }
        }
        
        // Returns the diseases treated by the designation
        var relatedDiseases: [String] {
            switch self {
            case .generalPractitioner: return ["fever", "cold", "flu"]
            case .pediatrician: return ["childhood illnesses", "growth disorders"]
            case .cardiologist: return ["heart disease", "hypertension"]
            case .dermatologist: return ["skin conditions", "acne"]
            case .neurologist: return ["migraines", "seizures", "neuropathy"]
            }
        }

        // Returns the consultation interval associated with the designation
        var interval: String {
            switch self {
            case .generalPractitioner: return "30"
            case .pediatrician: return "10"
            case .cardiologist: return "15"
            case .dermatologist: return "20"
            case .neurologist: return "25"
            }
        }
    static var withSelectOption: [DoctorDesignation?] {
        return [nil] + DoctorDesignation.allCases
    }
}

struct Offers: Codable,Hashable {
    var id:String?
    var image:String
    var hyperlink:String
    
    init(id: String? = nil, image: String, hyperlink: String) {
        self.id = id
        self.image = image
        self.hyperlink = hyperlink
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.image = try container.decode(String.self, forKey: .image)
        self.hyperlink = try container.decode(String.self, forKey: .hyperlink)
    }
}



