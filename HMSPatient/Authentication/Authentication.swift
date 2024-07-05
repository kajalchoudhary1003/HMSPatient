import SwiftUI

struct Authentication: View {
    @State private var countryCode: String = "+91"
    @State private var mobileNumber: String = ""
    @State private var isOtpViewActive = false
    @StateObject private var authManager = AuthManager()

    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading) {
                    Text("Welcome to")
                        .font(.title)
                        .bold()
                        .padding(.top, 50)
                        .padding(.bottom, 5)

                    Text("Mediflex")
                        .font(.title)
                        .foregroundColor(Color(red: 0.0, green: 0.49, blue: 0.45))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 30)

                Spacer()

                Image("Group 114")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 400) // Adjust the height as needed
                    .padding(.bottom, 10)

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
                        .background(Color(red: 0.0, green: 0.49, blue: 0.45))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)

                Spacer()
            }
            .navigationDestination(isPresented: $isOtpViewActive) {
                OtpView(authManager: authManager, phoneNumber: "\(countryCode)\(mobileNumber)")
            }
            .navigationBarHidden(true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Authentication()
    }
}