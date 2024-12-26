import SwiftUI
import PhotosUI

struct CoverImageSelector: View {
    @Binding var book: Book
    @State private var selectedItem: PhotosPickerItem?
    @State private var coverImageData: Data?
    @State private var showingImageSource = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Cover Image Preview
            Group {
                if let coverImageData,
                   let uiImage = UIImage(data: coverImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 240, height: 320)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 5)
                } else {
                    placeholderView
                }
            }
            .onTapGesture {
                showingImageSource = true
            }
            
            // Image Source Selection Buttons
            VStack(spacing: 16) {
                Button(action: {
                    // AI logic will be added later
                }) {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("AI ile Oluştur")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                PhotosPicker(selection: $selectedItem,
                           matching: .images,
                           photoLibrary: .shared()) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Galeriden Seç")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    coverImageData = data
                    book.coverImage = data.base64EncodedString()
                }
            }
        }
    }
    
    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.secondary.opacity(0.1))
            .frame(width: 240, height: 320)
            .overlay(
                VStack(spacing: 12) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("Kapak Görseli Ekle")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            )
    }
}

struct AIPromptView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var prompt: String
    @Binding var isGenerating: Bool
    let onGenerate: (String) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Kapak görseli için AI'ya ne çizmesini istediğinizi anlatın")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                TextEditor(text: $prompt)
                    .frame(height: 120)
                    .padding(8)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                // Style Selection (örnek stiller)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(["Gerçekçi", "Disney Charactor", "Suluboya", "Pixel Art"], id: \.self) { style in
                            styleButton(style)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Button(action: {
                    isGenerating = true
                    onGenerate(prompt)
                    dismiss()
                }) {
                    HStack {
                        Text("Oluştur")
                        if isGenerating {
                            ProgressView()
                                .tint(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(prompt.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(prompt.isEmpty || isGenerating)
                .padding()
            }
            .navigationTitle("AI Görsel Oluştur")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func styleButton(_ style: String) -> some View {
        Text(style)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.secondary.opacity(0.1))
            .clipShape(Capsule())
    }
}

// Preview için
struct CoverImageSelector_Previews: PreviewProvider {
    static var previews: some View {
        CoverImageSelector(book: .constant(Book()))
    }
}
