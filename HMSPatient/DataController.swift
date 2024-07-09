import Foundation
import FirebaseDatabase

class DataController {
    private let database = Database.database().reference()
    
    // Save user data to the database
    func saveUser(userId: String, user: User, completion: @escaping (Bool) -> Void) {
        let userDict: [String: Any] = [
            "firstName": user.firstName,
            "lastName": user.lastName,
            "dateOfBirth": user.dateOfBirth,
            "gender": user.gender,
            "bloodGroup": user.bloodGroup,
            "emergencyPhone": user.emergencyPhone
        ]
        
        database.child("users").child(userId).setValue(userDict) { error, _ in
            if let error = error {
                print("Error saving user data: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    // Check if the user data exists in the database
    func checkIfUserExists(userId: String, completion: @escaping (Bool) -> Void) {
        database.child("users").child(userId).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
