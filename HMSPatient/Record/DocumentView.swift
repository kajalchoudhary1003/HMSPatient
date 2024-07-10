import SwiftUI
import PDFKit

struct DocumentView: View {
    let record: Record

    var body: some View {
        GeometryReader { geometry in
            VStack {
                if record.fileType == .image {
                    AsyncImage(url: URL(string: record.fileURL)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width, height: geometry.size.height)
                        } else if phase.error != nil {
                            Text("Failed to load image")
                        } else {
                            ProgressView()
                        }
                    }
                } else if record.fileType == .pdf {
                    PDFKitView(url: URL(string: record.fileURL)!)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else {
                    Text("Unsupported file type")
                }
            }
            .navigationTitle(record.title)
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        DispatchQueue.global(qos: .background).async {
            let document = PDFDocument(url: self.url)
            DispatchQueue.main.async {
                pdfView.document = document
            }
        }
        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
        DispatchQueue.global(qos: .background).async {
            let document = PDFDocument(url: self.url)
            DispatchQueue.main.async {
                pdfView.document = document
            }
        }
    }
}
