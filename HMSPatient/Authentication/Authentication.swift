import SwiftUI

struct Authentication: View {
    @State private var countryCode: String = "+91"
    @State private var mobileNumber: String = ""
    @State private var isOtpViewActive = false
    @State private var isValidPhoneNumber = false // Track if the phone number is valid
    @State private var errorMessage = "" // Track error message for invalid phone number
    @StateObject private var authManager = AuthManager()

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
                        .overlay(Rectangle().frame(height: 1).padding(.top, 35))
                        .foregroundColor(Color.gray)

                    TextField("Mobile number", text: $mobileNumber)
                        .keyboardType(.numberPad)
                        .padding(.bottom, 5)
                        .overlay(Rectangle().frame(height: 1).padding(.top, 35))
                        .foregroundColor(Color.gray)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)

                // Error message for invalid phone number
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 10)
                    .opacity(errorMessage.isEmpty ? 0 : 1) // Show only when errorMessage is not empty

                // Continue button with validation
                Button(action: {
                    let phoneNumber = "\(countryCode)\(mobileNumber)"
                    authManager.sendCode(phoneNumber: phoneNumber) { success in
                        if success {
                            isOtpViewActive = true
                        } else {
                            // Handle error (show an alert, etc.)
                        }
                    }
                }) {
                    Text("Continue")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isValidPhoneNumber ? Color(red: 0.0, green: 0.49, blue: 0.45) : Color.gray)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
                .disabled(!isValidPhoneNumber) // Disable button if phone number is invalid

                Spacer()
            }
            .onChange(of: mobileNumber) { newValue in
                // Validate phone number whenever mobileNumber changes
                if newValue.count > 10 {
                    errorMessage = "Please enter correct phone number"
                    isValidPhoneNumber = false
                } else {
                    errorMessage = ""
                    isValidPhoneNumber = isValidMobileNumber(newValue)
                }
            }
            .navigationDestination(isPresented: $isOtpViewActive) {
                OtpView(authManager: authManager, phoneNumber: "\(countryCode)\(mobileNumber)")
            }
            .navigationBarHidden(true)
        }
    }

    // Function to validate a 10-digit mobile number
    private func isValidMobileNumber(_ number: String) -> Bool {
        let mobileNumberRegex = #"^\d{10}$"#
        return NSPredicate(format: "SELF MATCHES %@", mobileNumberRegex).evaluate(with: number)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Authentication()
    }
}
