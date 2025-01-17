import SwiftUI
import FirebaseAuth

struct PatientProfileView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -13, to: Date()) ?? Date()
    @State private var gender: String = "Select"
    @State private var bloodGroup: String = "Select"
    @State private var emergencyPhone: String = ""
    @State private var profileImage: Image? = nil
    @State private var isAddingEmergencyPhone = false
    @State private var isEditing = false // Added state variable for edit mode
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    @Environment(\.presentationMode) var presentationMode

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
                Spacer()
                Button(isEditing ? "Done" : "Edit") {
                    // Toggle edit mode
                    isEditing.toggle()
                    if !isEditing {
                        saveUserData()
                    }
                }
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
                    ZStack {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 100, height: 100)
                        Text(getInitials(firstName: firstName, lastName: lastName))
                            .foregroundColor(.white)
                            .font(.largeTitle)
                    }
                }
            }

            Form {
                Section(header: Text("Personal Information")) {
                    TextField("First name", text: $firstName)
                        .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification)) { _ in
                            firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                        .onChange(of: firstName) { newValue in
                            if newValue.count > 25 {
                                firstName = String(newValue.prefix(25))
                            }
                        }
                        .overlay(
                            Text("\(firstName.count)/25")
                                .font(.caption)
                                .foregroundColor(firstName.count > 25 ? Color(UIColor.systemRed) : .gray)
                                .padding(.trailing, 8)
                                .opacity(isEditing ? 1 : 0),
                            alignment: .trailing
                        )
                        .disabled(!isEditing) // Disable editing when not in edit mode
                    TextField("Last name", text: $lastName)
                        .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification)) { _ in
                            lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                        .onChange(of: lastName) { newValue in
                            if newValue.count > 25 {
                                lastName = String(newValue.prefix(25))
                            }
                        }
                        .overlay(
                            Text("\(lastName.count)/25")
                                .font(.caption)
                                .foregroundColor(lastName.count > 25 ? Color(UIColor.systemRed) : .gray)
                                .padding(.trailing, 8)
                                .opacity(isEditing ? 1 : 0),
                            alignment: .trailing
                        )
                        .disabled(!isEditing) // Disable editing when not in edit mode
                }
                
                Section(header: Text("Details")) {
                    DatePicker("Date Of Birth", selection: $dateOfBirth, in: ageRange, displayedComponents: .date)
                        .disabled(!isEditing) // Disable editing when not in edit mode
                    Picker("Gender", selection: $gender) {
                        ForEach(["Select", "Male", "Female", "Other"], id: \.self) {
                            Text($0)
                        }
                    }
                    .disabled(!isEditing) // Disable editing when not in edit mode
                    Picker("Blood Group", selection: $bloodGroup) {
                        ForEach(["Select", "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"], id: \.self) {
                            Text($0)
                        }
                    }
                    .disabled(!isEditing) // Disable editing when not in edit mode
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
                            .disabled(!isEditing) // Disable editing when not in edit mode
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
                        .disabled(!isEditing) // Disable editing when not in edit mode
                    }
                }
                
                VStack {
                    Button(action: {
                        logout()
                    }) {
                        Text("Log out")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color(UIColor.systemRed))
                            .font(.title2).fontWeight(.regular)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .background(Color("BackgroundColor"))
        .navigationBarBackButtonHidden(true)
        .onAppear {
            DataController.shared.fetchCurrentUserData { user, image in
                if let user = user {
                    self.firstName = user.firstName
                    self.lastName = user.lastName
                    if let dob = ISO8601DateFormatter().date(from: user.dateOfBirth) {
                        self.dateOfBirth = dob
                    }
                    self.gender = user.gender
                    self.bloodGroup = user.bloodGroup
                    self.emergencyPhone = user.emergencyPhone
                }
                self.profileImage = image
            }
        }
    }
    
    
    func logout() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
            UserDefaults.standard.set(false, forKey: "isLoggedIn") // Clear login state
            navigateToScreen(screen: Authentication())
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }

       
       
       // Function to navigate to different screens
        func navigateToScreen<Screen: View>(screen: Screen) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if let window = windowScene.windows.first {
                    window.rootViewController = UIHostingController(rootView: screen)
                    window.makeKeyAndVisible()
                }
            }
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

        DataController.shared.saveUser(userId: userId, user: user) { success in
            if !success {
                // Handle error (show an alert, etc.)
            }
        }
    }

    func getInitials(firstName: String, lastName: String) -> String {
        let firstInitial = firstName.first.map { String($0) } ?? ""
        let lastInitial = lastName.first.map { String($0) } ?? ""
        return firstInitial + lastInitial
    }

    var ageRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let now = Date()
        let minAge = calendar.date(byAdding: .year, value: -100, to: now)!
        let maxAge = calendar.date(byAdding: .year, value: -13, to: now)!
        return minAge...maxAge
    }
}

#Preview {
    PatientProfileView()
}
