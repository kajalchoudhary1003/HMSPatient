import SwiftUI
import AVFoundation

enum FileType: String {
    case audio
    case image
    case pdf
}

struct Record: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let fileURL: String // URL to the file in Firebase Storage
    let fileType: FileType // Add file type information
}

struct RecordCard: View {
    let record: Record
    let isExpanded: Bool
    let onTap: () -> Void
    @State private var audioPlayer: AVAudioPlayer?
    @State private var showingFile = false

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
        .background(Color("SecondaryColor"))
        .cornerRadius(10)
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
}

struct Record_Previews: PreviewProvider {
    static var previews: some View {
        RecordCard(record: Record(title: "Sample", date: "Today", fileURL: "", fileType: .audio), isExpanded: true, onTap: {})
    }
}
