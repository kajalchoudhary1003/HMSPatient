import SwiftUI
import FirebaseAuth
import AVFoundation
import MobileCoreServices
import FirebaseStorage
import Zip

struct RecordsView: View {
    @State private var searchText = ""
    @State private var expandedId: UUID?
    @State private var records: [Record] = []
    @State private var isShowingDocumentPicker = false
    @State private var userId: String = Auth.auth().currentUser?.uid ?? "" // Get the current user's ID
    @State private var selectedUrls: [URL] = [] // To hold selected URLs for upload
    @State private var isProcessing = false
    @State private var processingMessage = ""
    @State private var isLoading = true
    
    private let dataController = DataController()

    var body: some View {
        NavigationView {
            ZStack {
                Color.customBackground
                
                VStack {
                    if isProcessing {
                        VStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Text(processingMessage)
                                .padding()
                        }
                    } else if isLoading {
                        ProgressView("Fetching documents...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .onAppear {
                                fetchRecords()
                            }
                    } else if records.isEmpty {
                        VStack {
                            Image(systemName: "doc.text.magnifyingglass")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                            Text("No Documents Available")
                                .font(.title)
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                            Text("Please upload documents to manage them here.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.top, 4)
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 20) {
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
                                .onDelete(perform: confirmDeleteRecords)
                            }
                            .padding()
                        }
                    }
                }
            }
            .background(Color.customBackground)
            .searchable(text: $searchText, prompt: "Search")
            .navigationTitle("Records")
            .navigationBarItems(trailing: Button(action: {
                isShowingDocumentPicker.toggle()
            }) {
                Image(systemName: "plus")
            })
            .fileImporter(
                isPresented: $isShowingDocumentPicker,
                allowedContentTypes: [.image, .pdf, .init("public.heic")!],
                allowsMultipleSelection: true
            ) { result in
                handleFiles(result: result)
            }
        }
        .background(Color.customBackground)
    }

    private func handleFiles(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            selectedUrls = urls
            confirmUploadFiles(urls: urls)
        case .failure(let error):
            print("Failed to select files: \(error.localizedDescription)")
        }
    }

    private func confirmUploadFiles(urls: [URL]) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            return
        }
        
        let alert = UIAlertController(title: "Upload Documents", message: "Are you sure you want to upload these documents?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Upload", style: .default, handler: { _ in
            self.processingMessage = "Uploading documents..."
            self.isProcessing = true
            self.uploadFiles(urls: urls)
        }))
        
        rootVC.present(alert, animated: true, completion: nil)
    }

    private func uploadFiles(urls: [URL]) {
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let zipFilePath = tempDirectory.appendingPathComponent("files.zip")

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Start accessing the security scoped resources
                for url in urls {
                    _ = url.startAccessingSecurityScopedResource()
                }
                
                // Create zip file
                try Zip.zipFiles(paths: urls, zipFilePath: zipFilePath, password: nil, progress: nil)

                // Stop accessing the security scoped resources
                for url in urls {
                    url.stopAccessingSecurityScopedResource()
                }

                // Upload to Firebase Storage
                self.dataController.uploadZippedFiles(userId: self.userId, localFile: zipFilePath) { result in
                    DispatchQueue.main.async {
                        self.isProcessing = false
                    }
                    switch result {
                    case .success(let fileURL):
                        let newRecord = Record(title: "New Record", date: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none), fileURL: fileURL, fileType: self.determineFileType(for: urls.first!))
                        self.saveRecord(record: newRecord)
                    case .failure(let error):
                        print("Upload failed: \(error.localizedDescription)")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isProcessing = false
                }
                print("Failed to zip files: \(error.localizedDescription)")
            }
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
        processingMessage = "Fetching documents..."
        isProcessing = true
        dataController.fetchCurrentUserDocuments { fetchedRecords in
            self.records = fetchedRecords
            self.isProcessing = false
            self.isLoading = false
        }
    }

    private func confirmDeleteRecords(at offsets: IndexSet) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            return
        }

        let alert = UIAlertController(title: "Delete Document", message: "Are you sure you want to delete this document?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.processingMessage = "Deleting document..."
            self.isProcessing = true
            self.deleteRecords(at: offsets)
        }))
        
        rootVC.present(alert, animated: true, completion: nil)
    }

    private func deleteRecords(at offsets: IndexSet) {
        offsets.forEach { index in
            let record = records[index]
            dataController.deleteDocument(userId: userId, documentId: record.id.uuidString, documentURL: record.fileURL) { success in
                DispatchQueue.main.async {
                    self.isProcessing = false
                    if success {
                        records.remove(at: index)
                    } else {
                        print("Failed to delete record")
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
            return .pdf // default to pdf if unknown
        }
    }
}
