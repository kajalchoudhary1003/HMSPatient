import Combine
import Firebase

class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var isNewUser: Bool = false

    private var verificationID: String?

    func sendCode(phoneNumber: String, completion: @escaping (Bool) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
                print("Error sending verification code: \(error.localizedDescription)")
                completion(false)
            } else {
                self.verificationID = verificationID
                completion(true)
            }
        }
    }

    func resendCode(phoneNumber: String, completion: @escaping (Bool) -> Void) {
        sendCode(phoneNumber: phoneNumber, completion: completion)
    }

    func verifyCode(verificationCode: String, completion: @escaping (Bool) -> Void) {
        guard let verificationID = verificationID else {
            completion(false)
            return
        }
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("Error verifying code: \(error.localizedDescription)")
                completion(false)
            } else if let authResult = authResult {
                self.isLoggedIn = true
                self.isNewUser = authResult.additionalUserInfo?.isNewUser ?? false
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    func checkLoginState() {
        isLoggedIn = Auth.auth().currentUser != nil
    }

    func signOut(completion: @escaping (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
            completion(true)
        } catch {
            completion(false)
        }
    }
}
