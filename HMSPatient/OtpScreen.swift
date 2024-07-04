import SwiftUI

struct OtpView: View {
    @State private var otpFields = ["", "", "", ""]
    @State private var navigateToProfileSetup = false

    var body: some View {
        VStack {
            Spacer().frame(height: 50) // Top spacer with fixed height

            Text("Enter the OTP")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.bottom, 30) // Bottom padding for title

            HStack(spacing: 10) { // OTP input fields
                ForEach(0..<4) { index in
                    TextField("", text: $otpFields[index])
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 50, height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
            }
            .padding(.bottom, 30) // Bottom padding for OTP fields

            HStack { // Resend code button
                Spacer()
                Button(action: {
                    // Action for resending code
                }) {
                    Text("Resend code")
                        .foregroundColor(.black)
                        .font(.system(size: 12))
                        .underline()
                }
            }
            .padding(.bottom, 30) // Bottom padding for resend button

            NavigationLink(destination: ProfileSetupView(), isActive: $navigateToProfileSetup) {
                Button(action: {
                    navigateToProfileSetup = true
                }) {
                    Text("Login")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.0, green: 0.49, blue: 0.45)) // Adjust the color as needed
                        .cornerRadius(8)
                }
                .padding(.horizontal, 30) // Horizontal padding for login button
            }

            Spacer() // Bottom spacer to fill remaining space
        }
        .padding(.horizontal, 30) // Horizontal padding for entire view
    }
}

struct OtpView_Previews: PreviewProvider {
    static var previews: some View {
        OtpView()
    }
}
