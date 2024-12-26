import SwiftUI



// MARK: - Main View
struct CharacterCreationForm: View {
    @Binding var character: Character
    @State private var showingStylePicker = false
    
    // Constants
    private let characterTraits = [
            "Personality": ["Cheerful", "Curious", "Brave", "Creative", "Thoughtful"],
            "Behavior": ["Adventurous", "Helpful", "Smart", "Careful", "Fun"],
            "Emotional": ["Loving", "Dreamer", "Empathetic", "Sensitive"]
        ]
        
        private let artStyles = [
            "Disney Charactor",
            "Realistic",
            "Watercolor",
            "Pixel Art",
            "3D",
            "Minimal"
        ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Karakter Tanımı
                VStack(alignment: .leading, spacing: 8) {
                    Text("Karakterini Tanımla")
                        .font(.headline)
                    
                    TextEditor(text: $character.description)
                        .frame(height: 120)
                        .padding(8)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(
                            Group {
                                if character.description.isEmpty {
                                    Text("Örnek: Uzun boylu, kızıl saçlı, mavi gözlü, genellikle spor kıyafetler giyen...")
                                        .foregroundColor(.gray)
                                        .padding(.leading, 16)
                                        .padding(.top, 16)
                                }
                            }
                        )
                    
                    // Hızlı İpuçları
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(["kıyafet", "saç", "göz", "boy", "aksesuar", "yaş", "meslek"], id: \.self) { tip in
                                Button(action: {
                                    if character.description.isEmpty {
                                        character.description = "\(tip): "
                                    } else {
                                        character.description += ", \(tip): "
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.blue)
                                        Text(tip)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                
                // Karakter Özellikleri
                VStack(alignment: .leading, spacing: 12) {
                    Text("Karakter Özellikleri")
                        .font(.headline)
                    
                    ForEach(characterTraits.keys.sorted(), id: \.self) { category in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(category)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            FlowLayoutCharacter(spacing: 8) {
                                ForEach(characterTraits[category] ?? [], id: \.self) { trait in
                                    traitButton(trait)
                                }
                            }
                        }
                    }
                }
                
                // Görsel Stil
                VStack(alignment: .leading, spacing: 12) {
                    Text("Görsel Stil")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(artStyles, id: \.self) { style in
                                styleButton(style)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private func traitButton(_ trait: String) -> some View {
        Button(action: {
            if character.traits.contains(trait) {
                character.traits.removeAll { $0 == trait }
            } else {
                character.traits.append(trait)
            }
        }) {
            Text(trait)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    character.traits.contains(trait) ?
                    Color.blue : Color.secondary.opacity(0.1)
                )
                .foregroundColor(
                    character.traits.contains(trait) ?
                    .white : .primary
                )
                .cornerRadius(20)
        }
    }
    
    private func styleButton(_ style: String) -> some View {
        Button(action: {
            character.style = style
        }) {
            Text(style)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    character.style == style ?
                    Color.blue : Color.secondary.opacity(0.1)
                )
                .foregroundColor(
                    character.style == style ?
                    .white : .primary
                )
                .cornerRadius(20)
        }
    }
}

// MARK: - Flow Layout
struct FlowLayoutCharacter: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return arrangeSubviews(sizes: sizes, proposal: proposal).size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let offsets = arrangeSubviews(sizes: sizes, proposal: proposal).offsets
        
        for (offset, subview) in zip(offsets, subviews) {
            subview.place(at: CGPoint(x: bounds.minX + offset.x, y: bounds.minY + offset.y), proposal: .unspecified)
        }
    }
    
    private func arrangeSubviews(sizes: [CGSize], proposal: ProposedViewSize) -> (offsets: [CGPoint], size: CGSize) {
        guard let containerWidth = proposal.width else {
            return (sizes.map { _ in .zero }, .zero)
        }
        
        var offsets: [CGPoint] = []
        var currentPosition: CGPoint = .zero
        var maxHeight: CGFloat = 0
        
        for size in sizes {
            if currentPosition.x + size.width > containerWidth {
                currentPosition.x = 0
                currentPosition.y += maxHeight + spacing
                maxHeight = 0
            }
            
            offsets.append(currentPosition)
            currentPosition.x += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }
        
        return (offsets, CGSize(width: containerWidth, height: currentPosition.y + maxHeight))
    }
}

// MARK: - Preview
struct CharacterCreationForm_Previews: PreviewProvider {
    static var previews: some View {
        CharacterCreationForm(character: .constant(Character()))
    }
}
