import SwiftUI

struct Authentication: View {
    @State private var countryCode: String = "+1"
    @State private var mobileNumber: String = "6505551234"
    @State private var isOtpViewActive = false
    @StateObject private var authManager = AuthManager()
    @State private var errorMessage = ""
    @State private var showErrorAlert = false
    @State private var navigateToHome = false
    @State private var validationMessage = " "
    
    var isFormValid: Bool {
        isValidPhoneNumber(mobileNumber)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    VStack(alignment: .leading) {
                        Text("Welcome to")
                            .font(.title3)
                            .padding(.top, 10)
                        Text("infyMed")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(Color(hex: "006666"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10)
                    
                    Spacer() // Pushes VStack content to the top
                }
                VStack(alignment: .trailing) {
                    Image("Doctor 3D")
                        .resizable()
                        .scaledToFit()
                        .padding(.bottom, 220)
                }
                
                // Login input section at the bottom
                VStack {
                    Spacer() // Pushes login section to the bottom
                    
                    VStack(alignment: .leading) {
                        Text("Enter your credentials")
                            .font(.headline)
                            .padding(5)
                            .padding(.top, 8)
                            .padding(.horizontal, 5)
                        
                        Text("Please confirm your country code and enter your phone number")
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "006666"))
                            .padding(5)
                            .padding(.bottom, 5)
                            .padding(.horizontal, 5)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                VStack(alignment: .leading) {
                                    TextField("+91", text: $countryCode)
                                        .keyboardType(.numberPad)
                                        .multilineTextAlignment(.center)
                                        .frame(width: 50)
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
                                    Rectangle()
                                        .frame(width: 50, height: 1)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
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
                                            validationMessage = isValidPhoneNumber(mobileNumber) ? "Yeah! Looks like a valid number" : "Phone number should be 10 digits"
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
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                            
                            Text(validationMessage)
                                .foregroundColor(isValidPhoneNumber(mobileNumber) ? Color(hex: "0E6B60") : Color(UIColor.systemRed))
                                .font(.caption)
                                .padding(5)
                            
                            Button(action: {
                                let phoneNumber = "\(countryCode)\(mobileNumber)"
                                                        if isFormValid {
                                                            authManager.sendCode(phoneNumber: phoneNumber) { success in
                                                                if success {
                                                                    DispatchQueue.main.async {
                                                                        isOtpViewActive = true
                                                                    }
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
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(hex: "006666"))
                                    Text("Continue")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                }
                                .frame(maxHeight: 22)
                                .padding(.horizontal, 5)
                                .padding(.vertical)
                            }
                        }
                        .padding(.vertical)
                        
                    }
                    .padding(.vertical, 5)
                    .background(Blur())
                    .padding(.horizontal, 6)
                    .cornerRadius(22)
                }
            }
            .padding(.bottom, 10)
            .navigationDestination(isPresented: $isOtpViewActive) {
                 OtpView(authManager: authManager, phoneNumber: "\(countryCode)\(mobileNumber)", navigateToHome: $navigateToHome)
             }
             .navigationDestination(isPresented: $navigateToHome) {
                 HomeView()
             }
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
