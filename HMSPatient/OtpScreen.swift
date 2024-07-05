import SwiftUI

struct OtpView: View {
    @State private var otpCode: String = ""
    @State private var isProfileSetupViewActive = false

    var body: some View {
        VStack {
            Text("Enter the OTP")
                .font(.subheadline)
                .padding(.bottom, 20)
            
            HStack() {
                ForEach(0..<4, id: \.self) { index in
                    otpDigitField(at: index)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
            
            NavigationLink(destination: ProfileSetupView(), isActive: $isProfileSetupViewActive) {
                Button(action: {
                    isProfileSetupViewActive = true
                }) {
                    Text("Verify")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .navigationBarTitle("OTP Verification", displayMode: .inline)
    }
    
    private func otpDigitField(at index: Int) -> some View {
        let binding = Binding<String>(
            get: {
                guard otpCode.count > index else { return "" }
                return String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: index)])
            },
            set: {
                if $0.count > 1 { return }
                if index < otpCode.count {
                    otpCode.remove(at: otpCode.index(otpCode.startIndex, offsetBy: index))
                    otpCode.insert(contentsOf: $0, at: otpCode.index(otpCode.startIndex, offsetBy: index))
                } else {
                    otpCode.append($0)
                }
            }
        )
        
        return TextField("", text: binding)
            .keyboardType(.numberPad)
            .frame(width: 40, height: 40)
            .font(.title)
            .multilineTextAlignment(.center)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
    }
}

struct OtpView_Previews: PreviewProvider {
    static var previews: some View {
        OtpView()
    }
}
