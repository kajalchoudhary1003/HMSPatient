import Foundation
import FirebaseDatabase
import FirebaseStorage
import Zip

class DataController {
    private let database = Database.database().reference()
    private let storage = Storage.storage().reference()
    
    // Save user data to the database
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
            if let error = error {
                print("Error saving user data: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    // Check if the user data exists in the database
    func checkIfUserExists(userId: String, completion: @escaping (Bool) -> Void) {
        database.child("patient_users").child(userId).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    // Upload zipped files to Firebase Storage and save document UIDs to the user's data in Firebase Database
    func uploadZippedFiles(userId: String, localFile: URL, completion: @escaping (Result<String, Error>) -> Void) {
        let fileName = "\(UUID().uuidString).zip"
        let storageRef = storage.child("users/\(userId)/zipped_files/\(fileName)") // User-specific directory
        
        storageRef.putFile(from: localFile, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
            } else {
                storageRef.downloadURL { url, error in
                    if let error = error {
                        completion(.failure(error))
                    } else if let url = url {
                        self.saveDocumentUID(userId: userId, documentURL: url.absoluteString)
                        completion(.success(url.absoluteString))
                    }
                }
            }
        }
    }

    // Save document UID to the user's data in Firebase Database
    private func saveDocumentUID(userId: String, documentURL: String) {
        let documentUID = UUID().uuidString
        database.child("patient_users").child(userId).child("documents").child(documentUID).setValue(documentURL)
    }

    // Fetch documents from the user's data in Firebase Database, download and unzip them
    func fetchDocuments(userId: String, completion: @escaping ([Record]) -> Void) {
        database.child("patient_users").child(userId).child("documents").observeSingleEvent(of: .value) { snapshot in
            var records: [Record] = []
            let group = DispatchGroup()
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let documentURL = childSnapshot.value as? String {
                    group.enter()
                    self.downloadAndUnzipFile(documentURL: documentURL) { result in
                        switch result {
                        case .success(let url):
                            let fileType = self.determineFileType(for: url)
                            let record = Record(title: url.lastPathComponent, date: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none), fileURL: url.absoluteString, fileType: fileType)
                            records.append(record)
                        case .failure(let error):
                            print("Failed to unzip file: \(error.localizedDescription)")
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

    // Download and unzip the files
    private func downloadAndUnzipFile(documentURL: String, completion: @escaping (Result<URL, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let storageRef = Storage.storage().reference(forURL: documentURL)
            let tempDirectory = FileManager.default.temporaryDirectory
            let zipFilePath = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("zip")
            
            storageRef.write(toFile: zipFilePath) { url, error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                } else {
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
    }

    private func determineFileType(for url: URL) -> FileType {
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "mp3":
            return .audio
        case "jpg", "jpeg", "png":
            return .image
        case "pdf":
            return .pdf
        default:
            return .pdf // default to pdf if unknown
        }
    }

    // Save record metadata to the database
    func saveRecord(record: Record, completion: @escaping (Bool) -> Void) {
        let recordDict: [String: Any] = [
            "title": record.title,
            "date": record.date,
            "fileURL": record.fileURL,
            "fileType": record.fileType.rawValue
        ]
        
        database.child("records").child(record.id.uuidString).setValue(recordDict) { error, _ in
            if let error = error {
                print("Error saving record: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}
