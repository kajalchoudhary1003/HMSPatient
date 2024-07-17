import Zip
import UIKit
import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class DataController {
    private var database = Database.database().reference()
    private let storage = Storage.storage().reference()
    private let currentUser = Auth.auth().currentUser?.uid
    static let shared = DataController()
    
    func saveUser(userId: String, user: User, completion: @escaping (Bool) -> Void) {
        let userDict: [String: Any] = [
            "firstName": user.firstName,
            "lastName": user.lastName,
            "dateOfBirth": user.dateOfBirth,
            "gender": user.gender,
            "bloodGroup": user.bloodGroup,
            "emergencyPhone": user.emergencyPhone
        ]
        
        database.child("patient_users").child(userId).setValue(userDict) { error, _ in
            completion(error == nil)
        }
    }
    
    func checkIfUserExists(userId: String, completion: @escaping (Bool) -> Void) {
        database.child("patient_users").child(userId).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }

    func uploadZippedFiles(userId: String, localFile: URL, completion: @escaping (Result<String, Error>) -> Void) {
        let fileName = "\(UUID().uuidString).zip"
        let storageRef = storage.child("users/\(userId)/zipped_files/\(fileName)")
        
        storageRef.putFile(from: localFile, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                storageRef.downloadURL { url, error in
                    if let url = url {
                        self.saveDocumentUID(userId: userId, documentURL: url.absoluteString)
                        completion(.success(url.absoluteString))
                    } else {
                        completion(.failure(error!))
                    }
                }
            }
        }
    }

    private func saveDocumentUID(userId: String, documentURL: String) {
        let documentUID = UUID().uuidString
        database.child("patient_users").child(userId).child("documents").child(documentUID).setValue(documentURL)
    }

    func fetchDocuments(userId: String, completion: @escaping ([Record]) -> Void) {
        database.child("patient_users").child(userId).child("documents").observeSingleEvent(of: .value) { snapshot in
            var records: [Record] = []
            let group = DispatchGroup()
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let documentURL = childSnapshot.value as? String {
                    group.enter()
                    self.downloadAndUnzipFile(documentURL: documentURL) { result in
                        if case .success(let url) = result {
                            let fileType = self.determineFileType(for: url)
                            let record = Record(title: url.lastPathComponent, date: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none), fileURL: url.absoluteString, fileType: fileType)
                            records.append(record)
                        }
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                completion(records)
            }
        }
    }

    func fetchCurrentUserDocuments(completion: @escaping ([Record]) -> Void) {
        guard let userId = currentUser else {
            completion([])
            return
        }
        fetchDocuments(userId: userId, completion: completion)
    }

    private func downloadAndUnzipFile(documentURL: String, completion: @escaping (Result<URL, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let storageRef = Storage.storage().reference(forURL: documentURL)
            let tempDirectory = FileManager.default.temporaryDirectory
            let zipFilePath = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("zip")
            
            storageRef.write(toFile: zipFilePath) { _, error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                
                do {
                    let unzipDirectory = tempDirectory.appendingPathComponent(UUID().uuidString)
                    try Zip.unzipFile(zipFilePath, destination: unzipDirectory, overwrite: true, password: nil)
                    if let fileURL = try FileManager.default.contentsOfDirectory(at: unzipDirectory, includingPropertiesForKeys: nil).first {
                        DispatchQueue.main.async {
                            completion(.success(fileURL))
                        }
                    } else {
                        throw NSError(domain: "DataController", code: 1, userInfo: [NSLocalizedDescriptionKey: "No file found after unzipping"])
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    private func determineFileType(for url: URL) -> FileType {
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "mp3":
            return .audio
        case "jpg", "jpeg", "png", "heic":
            return .image
        case "pdf":
            return .pdf
        default:
            return .pdf
        }
    }

    func saveRecord(record: Record, completion: @escaping (Bool) -> Void) {
        let recordDict: [String: Any] = [
            "title": record.title,
            "date": record.date,
            "fileURL": record.fileURL,
            "fileType": record.fileType.rawValue
        ]
        
        database.child("records").child(record.id.uuidString).setValue(recordDict) { error, _ in
            completion(error == nil)
        }
    }

    func deleteDocument(userId: String, documentId: String, documentURL: String, completion: @escaping (Bool) -> Void) {
        let documentRef = database.child("patient_users").child(userId).child("documents").child(documentId)
        let storageRef = Storage.storage().reference(forURL: documentURL)
        
        storageRef.delete { storageError in
            if let storageError = storageError {
                print("Error deleting file from storage: \(storageError.localizedDescription)")
                completion(false)
            } else {
                documentRef.removeValue { error, _ in
                    completion(error == nil)
                }
            }
        }
    }
    
    func fetchDoctors(byCategory category: DoctorDesignation? = nil, completion: @escaping ([Doctor]) -> Void) {
        let ref = database.child("doctors")
        ref.observeSingleEvent(of: .value) { snapshot in
            var doctors: [Doctor] = []
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let doctorData = childSnapshot.value as? [String: Any] {
                    print("Doctor data for snapshot \(childSnapshot.key): \(doctorData)")
                    if let doctor = Doctor(from: doctorData, id: childSnapshot.key) {
                        if let category = category {
                            if doctor.designation == category {
                                doctors.append(doctor)
                            }
                        } else {
                            doctors.append(doctor)
                        }
                    } else {
                        print("Failed to parse doctor data from snapshot: \(childSnapshot.key)")
                    }
                } else {
                    print("Failed to parse child snapshot")
                }
            }
            print("Fetched doctors: \(doctors.count)")
            completion(doctors)
        }
    }

    func saveAppointment(appointment: Appointment, completion: @escaping (Bool) -> Void) {
        guard let userId = currentUser else {
            completion(false)
            return
        }
        
        let appointmentDict: [String: Any] = [
            "patientID": userId,
            "doctorID": appointment.doctorID ?? "",
            "date": appointment.date.timeIntervalSince1970,
            "timeSlotID": appointment.timeSlotID
        ]
        
        let appointmentId = appointment.id ?? UUID().uuidString
        let appointmentRef = database.child("appointments").child(appointmentId)
        
        appointmentRef.setValue(appointmentDict) { [self] error, _ in
            if let error = error {
                print("Error saving appointment: \(error.localizedDescription)")
                completion(false)
            } else {
                let userAppointmentRef = database.child("patient_users").child(userId).child("appointments").child(appointmentId)
                userAppointmentRef.setValue(true) { error, _ in
                    completion(error == nil)
                }
            }
        }
    }
    
    // New Methods for fetching user data and profile image
    func fetchUser(userId: String, completion: @escaping (User?) -> Void) {
        database.child("patient_users").child(userId).observeSingleEvent(of: .value) { snapshot in
            guard let userDict = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: userDict, options: [])
                let user = try JSONDecoder().decode(User.self, from: jsonData)
                completion(user)
            } catch {
                print("Error decoding user data: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }

    func fetchProfileImage(userId: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let profileImageRef = storage.child("users/\(userId)/profile_image.jpg")
        profileImageRef.downloadURL { url, error in
            if let error = error {
                completion(.failure(error))
            } else if let url = url {
                completion(.success(url))
            }
        }
    }

    func saveUserProfileImageURL(userId: String, url: String) {
        database.child("patient_users").child(userId).child("profileImageURL").setValue(url)
    }

    // Method for fetching current user data and profile image
    func fetchCurrentUserData(completion: @escaping (User?, Image?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(nil, nil)
            return
        }
        fetchUser(userId: userId) { user in
            guard let user = user else {
                completion(nil, nil)
                return
            }
            self.fetchProfileImage(userId: userId) { result in
                switch result {
                case .success(let url):
                    if let data = try? Data(contentsOf: url), let uiImage = UIImage(data: data) {
                        completion(user, Image(uiImage: uiImage))
                    } else {
                        completion(user, nil)
                    }
                case .failure:
                    completion(user, nil)
                }
            }
        }
    }
}
