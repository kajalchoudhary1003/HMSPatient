import SwiftUI
import FirebaseAuth

struct ProfileSetupView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -13, to: Date()) ?? Date()
    @State private var gender: String = "Select"
    @State private var bloodGroup: String = "Select"
    @State private var emergencyPhone: String = ""
    @State private var profileImage: Image? = nil
    @State private var isAddingEmergencyPhone = false
    @State private var navigateToHome = false
    private let dataController = DataController()

    var isSaveDisabled: Bool {
        !isFormValid || (isAddingEmergencyPhone && !isEmergencyPhoneValid)
    }

    var isFormValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && gender != "Select" && bloodGroup != "Select" &&
        firstName.count <= 25 && lastName.count <= 25
    }

    var isEmergencyPhoneValid: Bool {
        let phoneRegEx = "^[0-9]{10}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phoneTest.evaluate(with: emergencyPhone)
    }

    var body: some View {
        VStack {
            HStack {
                Text("Set Profile")
                    .font(.largeTitle)
                    .bold()
                Spacer()
            }
            .padding([.leading, .trailing, .top])
            
            VStack {
                if let profileImage = profileImage {
                    profileImage
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: 100, height: 100)
                } else {
                    InitialsCircleView(initials: getInitials(from: firstName, and: lastName))
                        .frame(width: 150, height: 150)
                }
            }

            Form {
                Section(header: Text("Personal Information")) {
                    TextField("First name", text: $firstName)
                        .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification)) { _ in
                            firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                        .onChange(of: firstName) { _ in
                            updateProfileImage()
                            if firstName.count > 25 {
                                firstName = String(firstName.prefix(25))
                            }
                        }
                        .overlay(
                            Text("\(firstName.count)/25")
                                .font(.caption)
                                .foregroundColor(firstName.count > 25 ? Color(UIColor.systemRed) : .gray)
                                .padding(.trailing, 8),
                            alignment: .trailing
                        )
                    TextField("Last name", text: $lastName)
                        .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification)) { _ in
                            lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                        .onChange(of: lastName) { _ in
                            updateProfileImage()
                            if lastName.count > 25 {
                                lastName = String(lastName.prefix(25))
                            }
                        }
                        .overlay(
                            Text("\(lastName.count)/25")
                                .font(.caption)
                                .foregroundColor(lastName.count > 25 ? Color(UIColor.systemRed) : .gray)
                                .padding(.trailing, 8),
                            alignment: .trailing
                        )
                }

                Section(header: Text("Details")) {
                    DatePicker("Date Of Birth", selection: $dateOfBirth, in: ageRange, displayedComponents: .date)
                    Picker("Gender", selection: $gender) {
                        ForEach(["Select", "Male", "Female", "Other"], id: \.self) {
                            Text($0)
                        }
                    }
                    Picker("Blood Group", selection: $bloodGroup) {
                        ForEach(["Select", "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"], id: \.self) {
                            Text($0)
                        }
                    }
                }

                Section {
                    if isAddingEmergencyPhone {
                        TextField("Emergency Contact", text: $emergencyPhone)
                            .keyboardType(.phonePad)
                            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification)) { _ in
                                emergencyPhone = emergencyPhone.trimmingCharacters(in: .whitespacesAndNewlines)
                            }
                            .onChange(of: emergencyPhone) { newValue in
                                let filtered = newValue.filter { "0123456789".contains($0) }
                                if emergencyPhone != filtered {
                                    emergencyPhone = filtered
                                }
                                if emergencyPhone.count > 10 {
                                    emergencyPhone = String(emergencyPhone.prefix(10))
                                }
                            }
                            .overlay(
                                Text("\(emergencyPhone.count)/10")
                                    .font(.caption)
                                    .foregroundColor(emergencyPhone.count > 10 ? Color(UIColor.systemRed) : .gray)
                                    .padding(.trailing, 8),
                                alignment: .trailing
                            )
                        if !isEmergencyPhoneValid && !emergencyPhone.isEmpty {
                            Text("Phone number should be 10 digits")
                                .foregroundColor(Color(UIColor.systemRed))
                                .font(.caption)
                        }
                    } else {
                        Button(action: {
                            isAddingEmergencyPhone.toggle()
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                                Text("Add emergency phone")
                            }
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: HomeView(), isActive: $navigateToHome) {
                    Button(action: {
                        saveUserData()
                    }) {
                        Text("Done")
                    }
                    .disabled(isSaveDisabled)
                }
            }
        }
        .onAppear {
            updateProfileImage()
        }
    }

    func updateProfileImage() {
        profileImage = nil // Reset the profile image
    }

    func getInitials(from firstName: String, and lastName: String) -> String {
        let firstInitial = firstName.first?.uppercased() ?? ""
        let lastInitial = lastName.first?.uppercased() ?? ""
        return "\(firstInitial)\(lastInitial)"
    }

    func saveUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let user = User(
            firstName: firstName,
            lastName: lastName,
            dateOfBirth: dateOfBirth.ISO8601Format(),
            gender: gender,
            bloodGroup: bloodGroup,
            emergencyPhone: emergencyPhone
        )

        dataController.saveUser(userId: userId, user: user) { success in
            if success {
                navigateToHome = true
            } else {
                // Handle error (show an alert, etc.)
            }
        }
    }

    var ageRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let now = Date()
        let minAge = calendar.date(byAdding: .year, value: -100, to: now)!
        let maxAge = calendar.date(byAdding: .year, value: -13, to: now)!
        return minAge...maxAge
    }
}

extension Date {
    func ISO8601Format() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}

struct InitialsCircleView: View {
    var initials: String

    var body: some View {
        Text(initials)
            .font(.largeTitle)
            .foregroundColor(.white)
            .frame(width: 150, height: 150)
            .background(Circle().fill(Color.customPrimary))
    }
}

struct ProfileSetupView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSetupView()
    }
}
