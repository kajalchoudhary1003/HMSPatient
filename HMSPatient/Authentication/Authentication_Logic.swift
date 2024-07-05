import SwiftUI
import FirebaseAuth

class AuthManager: ObservableObject {
    @Published var verificationID: String = ""
    
    func sendCode(phoneNumber: String, completion: @escaping (Bool) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print("Error in sending code: \(error.localizedDescription)")
                completion(false)
            } else {
                self.verificationID = verificationID ?? ""
                completion(true)
            }
        }
    }
    
    func verifyCode(verificationCode: String, completion: @escaping (Bool) -> Void) {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Error in verifying code: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func resendCode(phoneNumber: String, completion: @escaping (Bool) -> Void) {
        sendCode(phoneNumber: phoneNumber, completion: completion)
    }
}
