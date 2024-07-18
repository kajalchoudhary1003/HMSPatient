//import Foundation
//import BackgroundTasks
//import FirebaseAuth
//import FirebaseDatabase
//import FirebaseStorage
//
//class BackgroundTasks {
//    static let shared = BackgroundTasks()
//
//    func registerBackgroundTasks() {
//        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.yourapp.fetchDocuments", using: nil) { task in
//            self.handleFetchDocumentsTask(task: task as! BGProcessingTask)
//        }
//    }
//
//    func scheduleFetchDocumentsTask() {
//        let request = BGProcessingTaskRequest(identifier: "com.yourapp.fetchDocuments")
//        request.requiresNetworkConnectivity = true // Ensure there's network connectivity
//        request.requiresExternalPower = false
//
//        do {
//            try BGTaskScheduler.shared.submit(request)
//        } catch {
//            print("Failed to schedule background task: \(error)")
//        }
//    }
//
//    private func handleFetchDocumentsTask(task: BGProcessingTask) {
//        scheduleFetchDocumentsTask() // Schedule the next background fetch
//
//        let dataController = DataController()
//        guard let userId = Auth.auth().currentUser?.uid else {
//            task.setTaskCompleted(success: false)
//            return
//        }
//
//        dataController.fetchDocuments(userId: userId) { records in
//            // Process fetched records
//            for record in records {
//                dataController.downloadAndUnzipFile(documentURL: record.fileURL) { result in
//                    switch result {
//                    case .success(let url):
//                        // Handle the unzipped file
//                        print("Unzipped file at: \(url)")
//                    case .failure(let error):
//                        print("Failed to unzip file: \(error.localizedDescription)")
//                    }
//                }
//            }
//            task.setTaskCompleted(success: true)
//        }
//    }
//}
