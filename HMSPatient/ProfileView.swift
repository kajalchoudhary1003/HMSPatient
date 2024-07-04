import SwiftUI

struct ProfileSetupView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var dateOfBirth: Date = Date()
    @State private var gender: String = "Select"
    @State private var bloodGroup: String = "Select"
    @State private var emergencyPhone: String = ""
    @State private var profileImage: Image? = nil
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var isAddingEmergencyPhone = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingActionSheet = false
    @State private var navigateToHome = false

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
                        Image(systemName: "person.circle")
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(width: 150, height: 150)
                    }

                    Button("Edit") {
                        showingActionSheet = true
                    }
                    .padding()
                }

                Form {
                    Section(header: Text("Personal Information")) {
                        TextField("First name", text: $firstName)
                        TextField("Last name", text: $lastName)
                    }

                    Section(header: Text("Details")) {
                        DatePicker("Date Of Birth", selection: $dateOfBirth, displayedComponents: .date)
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
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: HomeView(), isActive: $navigateToHome) {
                        Button(action: {
                            // Action for Done button
                            navigateToHome = true
                        }) {
                            Text("Done")
                        }
                    }
                }
            }
    }

    func loadImage() {
        guard let inputImage = inputImage else { return }
        profileImage = Image(uiImage: inputImage)
    }
}

struct ProfileSetupView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSetupView()
    }
}
