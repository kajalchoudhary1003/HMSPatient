//import Foundation
//import FirebaseFirestoreSwift
//
//struct Hospital: Codable, Identifiable, Equatable {
//    @DocumentID var id: String?
//    var name: String
//    var email: String
//    var phone: String
//    var admins: [Admin]
//    var address: String
//    var city: String
//    var country: String
//    var zipCode: String
//    var type: String
//    var latitude: Double
//    var longitude: Double
//    
//    init(id: String? = nil, name: String, email: String, phone: String, admins: [Admin], address: String, city: String, country: String, zipCode: String, type: String, latitude: Double, longitude: Double) {
//        self.id = id
//        self.name = name
//        self.email = email
//        self.phone = phone
//        self.admins = admins
//        self.address = address
//        self.city = city
//        self.country = country
//        self.zipCode = zipCode
//        self.type = type
//        self.latitude = latitude
//        self.longitude = longitude
//    }
//
//    // Equatable conformance to compare two Hospital instances
//    static func == (lhs: Hospital, rhs: Hospital) -> Bool {
//        return lhs.id == rhs.id
//    }
//
//    // Converts the Hospital instance to a dictionary
//    func toDictionary() -> [String: Any] {
//        return [
//            "id": id ?? UUID().uuidString,
//            "name": name,
//            "address": address,
//            "phone": phone,
//            "email": email,
//            "type": type,
//            "city": city,
//            "country": country,
//            "zipCode": zipCode,
//            "latitude": latitude,
//            "longitude": longitude,
//            "admins": admins.map { $0.toDictionary() }
//        ]
//    }
//
//    // Initializes a Hospital instance from a dictionary
//    init?(from dictionary: [String: Any], id: String) {
//        guard let name = dictionary["name"] as? String,
//              let address = dictionary["address"] as? String,
//              let phone = dictionary["phone"] as? String,
//              let email = dictionary["email"] as? String,
//              let type = dictionary["type"] as? String,
//              let city = dictionary["city"] as? String,
//              let country = dictionary["country"] as? String,
//              let zipCode = dictionary["zipCode"] as? String,
//              let latitude = dictionary["latitude"] as? Double,
//              let longitude = dictionary["longitude"] as? Double,
//              let adminsData = dictionary["admins"] as? [[String: Any]] else {
//            return nil
//        }
//        self.id = id
//        self.name = name
//        self.address = address
//        self.phone = phone
//        self.email = email
//        self.type = type
//        self.city = city
//        self.country = country
//        self.zipCode = zipCode
//        self.latitude = latitude
//        self.longitude = longitude
//        self.admins = adminsData.compactMap { Admin(from: $0) }
//    }
//}
