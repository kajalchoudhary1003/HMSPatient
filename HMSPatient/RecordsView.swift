import SwiftUI
import AVFoundation

struct RecordsView: View {
    @State private var searchText = ""
    @State private var expandedId: UUID?
    @State private var records: [Record] = [
        Record(title: "X-Ray Report", date: "May 15", audioURL: "audio1"),
        Record(title: "X-Ray Report", date: "May 16", audioURL: "audio2"),
        Record(title: "X-Ray Report", date: "May 17", audioURL: "audio3"),
        Record(title: "X-Ray Report", date: "May 18", audioURL: "audio4"),
        Record(title: "X-Ray Report", date: "May 19", audioURL: "audio5"),
        Record(title: "X-Ray Report", date: "May 20", audioURL: "audio6")
    ]
    @State private var showActionSheet = false
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage: UIImage?

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(records.filter {
                        searchText.isEmpty ? true : $0.title.localizedCaseInsensitiveContains(searchText)
                    }) { record in
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
            .searchable(text: $searchText, prompt: "Search")
            .navigationTitle("Records")
            .navigationBarItems(trailing: Button(action: {
                showActionSheet = true
            }) {
                Image(systemName: "plus")
            })
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(
                    title: Text("Add New Record"),
                    message: Text("Choose an option"),
                    buttons: [
                        .default(Text("Take Photo")) {
                            sourceType = .camera
                            showImagePicker = true
                        },
                        .default(Text("Upload from Device")) {
                            sourceType = .photoLibrary
                            showImagePicker = true
                        },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: $sourceType)
            }
        }
    }
}

struct Record: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let audioURL: String
}

struct RecordCard: View {
    let record: Record
    let isExpanded: Bool
    let onTap: () -> Void
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        VStack {
            Button(action: onTap) {
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
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    Text(record.title)
                        .padding(.top)
                    
                    HStack {
                        Button(action: playAudio) {
                            Image(systemName: "play.circle")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: stopAudio) {
                            Image(systemName: "stop.circle")
                                .font(.title)
                                .foregroundColor(.red)
                        }
                    }
                }
                .transition(.opacity)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 1)
    }
    
    func playAudio() {
        guard let url = Bundle.main.url(forResource: record.audioURL, withExtension: "mp3") else {
            print("Audio file not found: \(record.audioURL)")
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
}

struct RecordsView_Previews: PreviewProvider {
    static var previews: some View {
        RecordsView()
    }
}
