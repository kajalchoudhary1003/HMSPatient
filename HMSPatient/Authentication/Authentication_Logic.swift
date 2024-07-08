import SwiftUI
import FirebaseAuth

class AuthManager: ObservableObject {
    @Published var verificationID: String = ""
    
    /// Sends a verification code to the provided phone number.
        /// - Parameters:
        ///   - phoneNumber: The phone number to send the verification code to.
        ///   - completion: Completion block called after attempting to send the code.
        ///                 Returns `true` if sending succeeded, otherwise `false`.
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
    
    /// Verifies the received verification code.
        /// - Parameters:
        ///   - verificationCode: The verification code received via SMS.
        ///   - completion: Completion block called after attempting to verify the code.
        ///                 Returns `true` if verification succeeded, otherwise `false`.
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
    
    /// Resends the verification code to the provided phone number.
        /// - Parameters:
        ///   - phoneNumber: The phone number to resend the verification code to.
        ///   - completion: Completion block called after attempting to resend the code.
        ///                 Returns `true` if resending succeeded, otherwise `false`.
    func resendCode(phoneNumber: String, completion: @escaping (Bool) -> Void) {
        sendCode(phoneNumber: phoneNumber, completion: completion)
    }
}
