import SwiftUI

struct OtpView: View {
    @State private var otpFields = ["", "", "", "", "", ""]
    @State private var navigateToNextView = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @ObservedObject var authManager: AuthManager
    @FocusState private var focusedField: Int?
    @State private var phoneNumber: String

    init(authManager: AuthManager, phoneNumber: String) {
        self.authManager = authManager
        self._phoneNumber = State(initialValue: phoneNumber)
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
                        .foregroundColor(.black)
                        .font(.system(size: 12))
                        .underline()
                }
            }
            .padding(.bottom, 30) // Bottom padding for resend button

            Button(action: {
                let otpCode = otpFields.joined()
                authManager.verifyCode(verificationCode: otpCode) { success in
                    if success {
                        navigateToNextView = true
                    } else {
                        alertMessage = "The OTP you entered is incorrect. Please try again."
                        showAlert = true
                    }
                }
            }) {
                Text("Login")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.0, green: 0.49, blue: 0.45)) // Adjust the color as needed
                    .cornerRadius(8)
            }
            .padding(.horizontal, 30) // Horizontal padding for login button
            .navigationDestination(isPresented: $navigateToNextView) {
                if authManager.isNewUser {
                    ProfileSetupView()
                } else {
                    HomeView()
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Message"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }

            Spacer() // Bottom spacer to fill remaining space
        }
        .padding(.horizontal, 30) // Horizontal padding for entire view
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.focusedField = 0
            }
        }
    }
}

struct OtpView_Previews: PreviewProvider {
    static var previews: some View {
        OtpView(authManager: AuthManager(), phoneNumber: "+1234567890")
    }
}
