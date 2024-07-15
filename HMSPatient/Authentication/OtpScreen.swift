import SwiftUI

struct OtpView: View {
    @State private var otpFields = Array(repeating: "", count: 6)
    @State private var showAlert = false
    @State private var alertMessage = ""
    @ObservedObject var authManager: AuthManager
    @FocusState private var focusedField: Int?
    @Binding var navigateToHome: Bool
    @State private var phoneNumber: String
    @State private var navigateToSetupProfileView = false

    init(authManager: AuthManager, phoneNumber: String, navigateToHome: Binding<Bool>) {
        self.authManager = authManager
        self._phoneNumber = State(initialValue: phoneNumber)
        self._navigateToHome = navigateToHome
    }

    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Text("Enter the OTP")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.bottom, 30)

            HStack(spacing: 10) {
                ForEach(0..<6) { index in
                    TextField("", text: $otpFields[index])
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 50, height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .focused($focusedField, equals: index)
                        .onChange(of: otpFields[index]) { newValue in
                            if newValue.count > 1 {
                                otpFields[index] = String(newValue.prefix(1))
                            }
                            if !newValue.isEmpty && index < 5 {
                                focusedField = index + 1
                            }
                            if newValue.isEmpty && index > 0 {
                                focusedField = index - 1
                            }
                        }
                }
            }
            .padding(.bottom, 30)

            HStack {
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
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .underline()
                        .padding()
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }

            Spacer()

            Button(action: {
                let otp = otpFields.joined()
                if otp.count == 6 {
                    authManager.verifyCode(verificationCode: otp) { success in
                        if success {
                            if authManager.isNewUser {
                                navigateToHome = false
                                navigateToSetupProfileView = true
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
                Text("Sign In")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex:"0E6B60"))
                    .cornerRadius(10)
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 30)
        }
        .background(Color(hex:"ECEEEE"))
        .navigationDestination(isPresented: $navigateToSetupProfileView) {
            ProfileSetupView()
        }
    }
}

struct OtpView_Previews: PreviewProvider {
    static var previews: some View {
        OtpView(authManager: AuthManager(), phoneNumber: "+1234567890", navigateToHome: .constant(false))
    }
}
