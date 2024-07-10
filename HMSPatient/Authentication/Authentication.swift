import SwiftUI

struct Authentication: View {
    @State private var countryCode: String = "+91"
    @State private var mobileNumber: String = ""
    @State private var isOtpViewActive = false
    @StateObject private var authManager = AuthManager()
    @State private var errorMessage = ""
    @State private var showErrorAlert = false

    var isFormValid: Bool {
        isValidCountryCode(countryCode) && isValidPhoneNumber(mobileNumber)
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Header text
                VStack(alignment: .leading) {
                    Text("Welcome to")
                        .font(.title)
                        .padding(.top, 50)
                        .padding(.bottom, 5)

                    Text("Mediflex")
                        .font(.title)
                        .bold()
                        .foregroundColor(Color(red: 0.0, green: 0.49, blue: 0.45))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 30)

                Spacer()

                // Image
                Image("Doctor 3D")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 400) // Adjust the height as needed
                    .padding(.bottom, 10)

                // Instruction text
                VStack(alignment: .leading) {
                    Text("Enter your mobile number")
                        .font(.headline)
                        .padding(.bottom, 5)

                    Text("Please confirm your country code and enter your phone number")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 30)

                // Input fields for country code and mobile number
                HStack {
                    TextField("+91", text: $countryCode)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 80)
                        .padding(.bottom, 5)
                        .onChange(of: countryCode) { newValue in
                            let filtered = newValue.filter { "+0123456789".contains($0) }
                            if countryCode != filtered {
                                countryCode = filtered
                            }
                            if countryCode.count > 3 {
                                countryCode = String(countryCode.prefix(3))
                            }
                        }
                        .foregroundColor(Color.gray)
                        .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification)) { _ in
                            countryCode = countryCode.trimmingCharacters(in: .whitespacesAndNewlines)
                        }

                    TextField("Mobile number", text: $mobileNumber)
                        .keyboardType(.numberPad)
                        .padding(.bottom, 5)
                        .onChange(of: mobileNumber) { newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if mobileNumber != filtered {
                                mobileNumber = filtered
                            }
                            if mobileNumber.count > 10 {
                                mobileNumber = String(mobileNumber.prefix(10))
                            }
                        }
                        .overlay(
                            Text("\(mobileNumber.count)/10")
                                .font(.caption)
                                .foregroundColor(mobileNumber.count > 10 ? .red : .gray)
                                .padding(.trailing, 8),
                            alignment: .trailing
                        )
                        .foregroundColor(Color.gray)
                        .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification)) { _ in
                            mobileNumber = mobileNumber.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)

                // Error messages for invalid inputs
                if !isValidCountryCode(countryCode) && !countryCode.isEmpty {
                    Text("Invalid country code")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.bottom, 5)
                }
                if !isValidPhoneNumber(mobileNumber) && !mobileNumber.isEmpty {
                    Text("Phone number should be 10 digits")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.bottom, 5)
                }

                // Continue button
                Button(action: {
                    let phoneNumber = "\(countryCode)\(mobileNumber)"
                    if isFormValid {
                        authManager.sendCode(phoneNumber: phoneNumber) { success in
                            if success {
                                isOtpViewActive = true
                            } else {
                                errorMessage = "Failed to send OTP. Please try again."
                                showErrorAlert = true
                            }
                        }
                    } else {
                        errorMessage = "Please enter valid details."
                        showErrorAlert = true
                    }
                }) {
                    Text("Continue")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color(red: 0.0, green: 0.49, blue: 0.45) : Color.gray)
                        .cornerRadius(8)
                }
                .disabled(!isFormValid)
                .padding(.horizontal, 30)
                .padding(.bottom, 30)

                Spacer()
            }
            .navigationDestination(isPresented: $isOtpViewActive) {
                OtpView(authManager: authManager, phoneNumber: "\(countryCode)\(mobileNumber)")
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
        .onAppear {
            // Check if the user is new and navigate accordingly
            if !authManager.isNewUser {
                isOtpViewActive = false
            }
        }
    }

    // Validation functions
    func isValidCountryCode(_ code: String) -> Bool {
        let countryCodeRegEx = "^\\+[0-9]{1,3}$"
        let countryCodeTest = NSPredicate(format: "SELF MATCHES %@", countryCodeRegEx)
        return countryCodeTest.evaluate(with: code)
    }

    func isValidPhoneNumber(_ number: String) -> Bool {
        let phoneRegEx = "^[0-9]{10}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phoneTest.evaluate(with: number)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Authentication()
    }
}
