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
            let timeSlotDictionaries = dictionary["timeSlots"] as? [[String: Any]],
            let experience = dictionary["experience"] as? Int
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
        case neurologist = "Neurologist"
        case orthopedist = "Orthopedist"
        case gastroenterologist = "Gastroenterologist"
        case endocrinologist = "Endocrinologist"
        case oncologist = "Oncologist"
        case ophthalmologist = "Ophthalmologist"
        case otolaryngologist = "Otolaryngologist"
        case psychiatrist = "Psychiatrist"
        case rheumatologist = "Rheumatologist"
        case urologist = "Urologist"
        case nephrologist = "Nephrologist"
        case pulmonologist = "Pulmonologist"
        case hematologist = "Hematologist"
        case immunologist = "Immunologist"
        case infectiousDiseaseSpecialist = "Infectious Disease Specialist"
        case geriatrician = "Geriatrician"
        case allergist = "Allergist"
        case anesthesiologist = "Anesthesiologist"
        case plasticSurgeon = "Plastic Surgeon"
        case radiologist = "Radiologist"

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
            case .orthopedist: return "$140"
            case .gastroenterologist: return "$145"
            case .endocrinologist: return "$150"
            case .oncologist: return "$170"
            case .ophthalmologist: return "$135"
            case .otolaryngologist: return "$140"
            case .psychiatrist: return "$155"
            case .rheumatologist: return "$150"
            case .urologist: return "$145"
            case .nephrologist: return "$150"
            case .pulmonologist: return "$150"
            case .hematologist: return "$150"
            case .immunologist: return "$140"
            case .infectiousDiseaseSpecialist: return "$150"
            case .geriatrician: return "$130"
            case .allergist: return "$130"
            case .anesthesiologist: return "$180"
            case .plasticSurgeon: return "$200"
            case .radiologist: return "$150"
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
            case .orthopedist: return ["fractures", "arthritis", "sports injuries"]
            case .gastroenterologist: return ["IBS", "ulcers", "Crohn's disease"]
            case .endocrinologist: return ["diabetes", "thyroid disorders", "hormonal imbalances"]
            case .oncologist: return ["cancer", "tumors", "leukemia"]
            case .ophthalmologist: return ["glaucoma", "cataracts", "vision problems"]
            case .otolaryngologist: return ["sinusitis", "hearing loss", "tonsillitis"]
            case .psychiatrist: return ["depression", "anxiety", "bipolar disorder"]
            case .rheumatologist: return ["arthritis", "lupus", "fibromyalgia"]
            case .urologist: return ["UTIs", "kidney stones", "prostate issues"]
            case .nephrologist: return ["kidney disease", "hypertension", "electrolyte disorders"]
            case .pulmonologist: return ["asthma", "COPD", "lung cancer"]
            case .hematologist: return ["anemia", "hemophilia", "blood cancers"]
            case .immunologist: return ["allergies", "autoimmune diseases", "immune deficiencies"]
            case .infectiousDiseaseSpecialist: return ["HIV/AIDS", "tuberculosis", "malaria"]
            case .geriatrician: return ["dementia", "osteoporosis", "elderly care"]
            case .allergist: return ["allergies", "asthma", "eczema"]
            case .anesthesiologist: return ["pain management", "anesthesia"]
            case .plasticSurgeon: return ["reconstructive surgery", "cosmetic surgery", "burn treatment"]
            case .radiologist: return ["diagnostic imaging", "radiation therapy"]
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
            case .orthopedist: return "20"
            case .gastroenterologist: return "25"
            case .endocrinologist: return "25"
            case .oncologist: return "30"
            case .ophthalmologist: return "20"
            case .otolaryngologist: return "20"
            case .psychiatrist: return "30"
            case .rheumatologist: return "25"
            case .urologist: return "25"
            case .nephrologist: return "25"
            case .pulmonologist: return "25"
            case .hematologist: return "25"
            case .immunologist: return "20"
            case .infectiousDiseaseSpecialist: return "25"
            case .geriatrician: return "20"
            case .allergist: return "20"
            case .anesthesiologist: return "30"
            case .plasticSurgeon: return "40"
            case .radiologist: return "30"
            }
        }
    static var withSelectOption: [DoctorDesignation?] {
        return [nil] + DoctorDesignation.allCases
    }
}

