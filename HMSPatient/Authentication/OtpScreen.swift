import SwiftUI

struct OtpView: View {
    @State private var otpFields = ["1", "2", "3", "4", "5", "6"]
    @State private var showAlert = false
    @State private var alertMessage = ""
    @ObservedObject var authManager: AuthManager
    @FocusState private var focusedField: Int?
    @Binding var navigateToHome: Bool
    @State private var phoneNumber: String

    init(authManager: AuthManager, phoneNumber: String, navigateToHome: Binding<Bool>) {
        self.authManager = authManager
        self._phoneNumber = State(initialValue: phoneNumber)
        self._navigateToHome = navigateToHome
    }

    var body: some View {
        VStack {
            Spacer().frame(height: 50) // Top spacer with fixed height

            Text("Enter the OTP")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.bottom, 30) // Bottom padding for title

            HStack(spacing: 10) { // OTP input fields
                ForEach(0..<6) { index in
                    TextField("", text: Binding(
                        get: { otpFields[index] },
                        set: { newValue in
                            if newValue.count <= 1 && newValue.allSatisfy({ $0.isNumber }) {
                                otpFields[index] = newValue
                                if newValue.count == 1 {
                                    if index < 5 {
                                        focusedField = index + 1
                                    } else {
                                        focusedField = nil
                                    }
                                }
                            } else if newValue.isEmpty {
                                otpFields[index] = ""
                                if index > 0 {
                                    focusedField = index - 1
                                }
                            }
                        }
                    ))
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .frame(width: 50, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .focused($focusedField, equals: index)
                }
            }
            .padding(.bottom, 30) // Bottom padding for OTP fields

            HStack { // Resend code button
                Spacer()
                Button(action: {
                    authManager.resendCode(phoneNumber: phoneNumber) { success in
                        if success {
                            alertMessage = "A new OTP has been sent to your phone."
                            showAlert = true
                        } else {
                            alertMessage = "Failed to resend OTP. Please try again."
                            showAlert = true
                        }
                    }
                }) {
                    Text("Resend code")
                        .foregroundColor(.blue)
                        .padding()
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }

            Spacer()

            // Continue button
            Button(action: {
                let otp = otpFields.joined()
                if otp.count == 6 {
                    authManager.verifyCode(verificationCode: otp) { success in
                        if success {
                            // Navigate based on isNewUser flag
                            if authManager.isNewUser {
                                navigateToHome = false
                                navigateToSetupProfile()
                            } else {
                                navigateToHome = true
                            }
                        } else {
                            alertMessage = "Invalid OTP. Please try again."
                            showAlert = true
                        }
                    }
                } else {
                    alertMessage = "Please enter a 6-digit OTP."
                    showAlert = true
                }
            }) {
                Text("Continue")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
        .navigationDestination(isPresented: $navigateToSetupProfileView) {
            ProfileSetupView()
        }
    }

    @State private var navigateToSetupProfileView = false

    private func navigateToSetupProfile() {
        navigateToSetupProfileView = true
    }
}

struct OtpView_Previews: PreviewProvider {
    static var previews: some View {
        OtpView(authManager: AuthManager(), phoneNumber: "+1234567890", navigateToHome: .constant(false))
    }
}
