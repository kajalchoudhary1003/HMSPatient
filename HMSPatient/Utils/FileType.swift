import Foundation
import SwiftUI
import AVFoundation
import FirebaseAuth

enum FileType: String, Codable {
    case audio
    case image
    case pdf
}

struct Record: Identifiable, Codable {
    let id: UUID
    var title: String
    let date: String
    let fileURL: String // URL to the file in Firebase Storage
    let fileType: FileType // Add file type information
    
    init(id: UUID = UUID(), title: String, date: String, fileURL: String, fileType: FileType) {
        self.id = id
        self.title = title
        self.date = date
        self.fileURL = fileURL
        self.fileType = fileType
    }
}

struct RecordCard: View {
    let record: Record
    let isExpanded: Bool
    let onTap: () -> Void
    @State private var audioPlayer: AVAudioPlayer?
    @State private var showingRenameAlert = false
    @State private var showingShareSheet = false
    @State private var newTitle = ""
    @State private var showingDeleteConfirmation = false

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "doc.fill")
                    .foregroundColor(.gray)
                    .font(.largeTitle)
                
                VStack(alignment: .leading) {
                    Text(record.title)
                        .font(.headline)
                    Text(record.date)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    // Show context menu
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                }
                .contextMenu {
                    Button(action: {
                        newTitle = record.title
                        showingRenameAlert = true
                    }) {
                        Text("Rename")
                        Image(systemName: "pencil")
                    }

                    Button(action: {
                        if let url = URL(string: record.fileURL) {
                            let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                            UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
                        }
                    }) {
                        Text("Share")
                        Image(systemName: "square.and.arrow.up")
                    }

                    Button(action: {
                        showingDeleteConfirmation = true
                    }) {
                        Text("Delete")
                            .foregroundColor(.red)
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    Text(record.title)
                        .padding(.top)
                    
                    if record.fileType == .audio {
                        HStack {
                            Button(action: playAudio) {
                                Image(systemName: "play.circle")
                                    .font(.title)
                                    .foregroundColor(.blue)
                            }
                            
                            Button(action: stopAudio) {
                                Image(systemName: "stop.circle")
                                    .font(.title)
                                    .foregroundColor(Color(UIColor.systemRed))
                            }
                        }
                    }
                }
                .transition(.opacity)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .alert(isPresented: $showingRenameAlert) {
            Alert(
                title: Text("Rename Document"),
                message: Text("Enter a new name for the document."),
                primaryButton: .default(Text("Save"), action: renameDocument),
                secondaryButton: .cancel()
            )
        }
        .actionSheet(isPresented: $showingDeleteConfirmation) {
            ActionSheet(
                title: Text("Delete Document"),
                message: Text("Are you sure you want to delete this document? This action cannot be undone."),
                buttons: [
                    .destructive(Text("Delete"), action: deleteDocument),
                    .cancel()
                ]
            )
        }
    }
    
    func playAudio() {
        guard let url = URL(string: record.fileURL) else {
            print("Audio file not found: \(record.fileURL)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
    
    func stopAudio() {
        audioPlayer?.stop()
    }
    
    func renameDocument() {
        // Implement rename logic
        // Update record title and save to Firebase
        var newRecord = record
        newRecord.title = newTitle
        DataController.shared.saveRecord(record: newRecord) { success in
            if success {
                print("Successfully renamed document.")
            } else {
                print("Failed to rename document.")
            }
        }
    }
    
    func deleteDocument() {
        // Implement delete logic
        DataController.shared.deleteDocument(userId: Auth.auth().currentUser?.uid ?? "", documentId: record.id.uuidString, documentURL: record.fileURL) { success in
            if success {
                print("Successfully deleted document.")
            } else {
                print("Failed to delete document.")
            }
        }
    }
}

struct Record_Previews: PreviewProvider {
    static var previews: some View {
        RecordCard(record: Record(title: "Sample", date: "Today", fileURL: "", fileType: .audio), isExpanded: true, onTap: {})
    }
}
