import SwiftUI
import FirebaseAuth
import FirebaseStorage

struct PatientProfileView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -13, to: Date()) ?? Date()
    @State private var gender: String = "Select"
    @State private var bloodGroup: String = "Select"
    @State private var emergencyPhone: String = ""
    @State private var profileImage: Image? = nil
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var isAddingEmergencyPhone = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingActionSheet = false
    @State private var isEditing = false // Added state variable for edit mode
    
    @Environment(\.presentationMode) var presentationMode
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
                    Image(systemName: "person.circle")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: 150, height: 150)
                }

                if isEditing {
                    Button("Edit") {
                        showingActionSheet = true
                    }
                    .padding()
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
            }
            .scrollContentBackground(.hidden)
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage, sourceType: self.$sourceType)
            }
            .actionSheet(isPresented: $showingActionSheet) {
                ActionSheet(title: Text("Select Image"), message: Text("Choose a method"), buttons: [
                    .default(Text("Camera")) {
                        self.sourceType = .camera
                        self.showingImagePicker = true
                    },
                    .default(Text("Photo Library")) {
                        self.sourceType = .photoLibrary
                        self.showingImagePicker = true
                    },
                    .cancel()
                ])
            }
        }
        .background(Color(hex:"ECEEEE"))
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadUserData()
        }
    }

    func loadImage() {
        guard let inputImage = inputImage else { return }
        profileImage = Image(uiImage: inputImage)
        saveProfileImage(inputImage)
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
            if !success {
                // Handle error (show an alert, etc.)
            }
        }
    }

    func saveProfileImage(_ image: UIImage) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let imageData = image.jpegData(compressionQuality: 0.8)
        let storageRef = Storage.storage().reference().child("users/\(userId)/profile_image.jpg")
        storageRef.putData(imageData!, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading profile image: \(error.localizedDescription)")
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    return
                }
                guard let url = url else { return }
                self.dataController.saveUserProfileImageURL(userId: userId, url: url.absoluteString)
            }
        }
    }

    func loadUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        dataController.fetchUser(userId: userId) { user in
            guard let user = user else { return }
            self.firstName = user.firstName
            self.lastName = user.lastName
            if let dob = ISO8601DateFormatter().date(from: user.dateOfBirth) {
                self.dateOfBirth = dob
            }
            self.gender = user.gender
            self.bloodGroup = user.bloodGroup
            self.emergencyPhone = user.emergencyPhone
            
            dataController.fetchProfileImage(userId: userId) { result in
                switch result {
                case .success(let url):
                    if let data = try? Data(contentsOf: url), let uiImage = UIImage(data: data) {
                        self.profileImage = Image(uiImage: uiImage)
                    }
                case .failure(let error):
                    print("Error fetching profile image: \(error.localizedDescription)")
                }
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

#Preview {
    PatientProfileView()
}
