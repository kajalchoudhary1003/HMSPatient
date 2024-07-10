import SwiftUI
import AVFoundation
import MobileCoreServices
import FirebaseStorage
import Zip

struct RecordsView: View {
    @State private var searchText = ""
    @State private var expandedId: UUID?
    @State private var records: [Record] = []
    @State private var isShowingDocumentPicker = false
    @State private var userId: String = "user123" // Replace with actual user ID
    
    private let dataController = DataController()

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(records.filter {
                        searchText.isEmpty ? true : $0.title.localizedCaseInsensitiveContains(searchText)
                    }) { record in
                        NavigationLink(destination: DocumentView(record: record)) {
                            RecordCard(record: record, isExpanded: expandedId == record.id) {
                                if expandedId == record.id {
                                    expandedId = nil
                                } else {
                                    expandedId = record.id
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search")
            .navigationTitle("Records")
            .navigationBarItems(trailing: Button(action: {
                isShowingDocumentPicker.toggle()
            }) {
                Image(systemName: "plus")
            })
            .fileImporter(
                isPresented: $isShowingDocumentPicker,
                allowedContentTypes: [.image, .pdf],
                allowsMultipleSelection: true
            ) { result in
                handleFiles(result: result)
            }
            .onAppear {
                fetchRecords()
            }
        }
    }
    
    private func handleFiles(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            uploadFiles(urls: urls)
        case .failure(let error):
            print("Failed to select files: \(error.localizedDescription)")
        }
    }
    
    private func uploadFiles(urls: [URL]) {
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let zipFilePath = tempDirectory.appendingPathComponent("files.zip")

        do {
            // Create zip file
            try Zip.zipFiles(paths: urls, zipFilePath: zipFilePath, password: nil, progress: nil)

            // Upload to Firebase Storage
            dataController.uploadZippedFiles(userId: userId, localFile: zipFilePath) { result in
                switch result {
                case .success(let fileURL):
                    let newRecord = Record(title: "New Record", date: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none), fileURL: fileURL, fileType: determineFileType(for: urls.first!))
                    saveRecord(record: newRecord)
                case .failure(let error):
                    print("Upload failed: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Failed to zip files: \(error.localizedDescription)")
        }
    }
    
    private func saveRecord(record: Record) {
        dataController.saveRecord(record: record) { success in
            if success {
                fetchRecords()
            } else {
                print("Failed to save record")
            }
        }
    }

    private func fetchRecords() {
        dataController.fetchDocuments(userId: userId) { fetchedRecords in
            self.records = fetchedRecords
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
}
