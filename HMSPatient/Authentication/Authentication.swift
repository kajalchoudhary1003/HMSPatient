import SwiftUI

struct Authentication: View {
    @State private var countryCode: String = "+1"
    @State private var mobileNumber: String = "6505551234"
    @State private var isOtpViewActive = false
    @StateObject private var authManager = AuthManager()
    @State private var errorMessage = ""
    @State private var showErrorAlert = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
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
                            .foregroundColor(.customPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10)
                    
                    Spacer()
                }
                GeometryReader { geometry in
                    Image("Doctor 3D")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width)
                        .position(x: geometry.size.width / 2, y: geometry.size.height * 0.36)
                }

                VStack {
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("Enter your credentials")
                            .font(.headline)
                            .padding(5)
                            .padding(.top, 8)
                            .padding(.horizontal, 5)
                        
                        Text("Please confirm your country code and enter your phone number")
                            .font(.subheadline)
                            .foregroundColor(.customPrimary)
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
                                                .foregroundColor(mobileNumber.count > 10 ? Color(UIColor.systemRed) : .gray)
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
                                .foregroundColor(isValidPhoneNumber(mobileNumber) ? .customPrimary : Color(UIColor.systemRed))
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
                                        .fill(Color.customPrimary)
                                    Text("Continue")
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
            .background(Color.customBackground)
            .padding(.bottom, 10)
            .navigationDestination(isPresented: $isOtpViewActive) {
                OtpView(authManager: authManager, phoneNumber: "\(countryCode)\(mobileNumber)", navigateToHome: $isLoggedIn)
                    .environmentObject(authManager)
            }
            .navigationDestination(isPresented: $isLoggedIn) {
                HomeView() // Ensure HomeView() is the correct destination here
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                authManager.checkLoginState()
                if authManager.isLoggedIn {
                    isLoggedIn = true
                }
            }
        }
    }
    
    private func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneNumberRegex = "^[0-9]{10}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
        return phoneTest.evaluate(with: phoneNumber)
    }
}
