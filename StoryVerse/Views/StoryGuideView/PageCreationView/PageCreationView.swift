import SwiftUI

struct StoryPageCreationView: View {
    @Binding var book: Book
    @ObservedObject var viewModel: BookCreationViewModel
    @State private var generatedImages: [UIImage] = []

    @State private var sceneTexts: [String] = Array(repeating: "", count: 6)
    @State private var hideCharacterFlags: [Bool] = Array(repeating: false, count: 6)
    @State private var currentSceneIndex: Int = 0
    @State private var isGenerating = false
    @State private var showingFormatGuide = false
    @State private var showGuideSection = true
    
    private let maxScenes = 6
    
    var currentSceneCount: Int {
        sceneTexts.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            if !generatedImages.isEmpty {
                         ScrollView(.horizontal, showsIndicators: false) {
                             LazyHStack(spacing: 12) {
                                 ForEach(generatedImages.indices, id: \.self) { index in
                                     Image(uiImage: generatedImages[index])
                                         .resizable()
                                         .scaledToFit()
                                         .frame(height: 200)
                                         .cornerRadius(12)
                                 }
                             }
                             .padding()
                         }
                         .frame(height: 220)
                     }
            ScrollView {
                VStack(spacing: 24) {
                    sceneProgressSection
                    characterSection
                    formatGuideSection
                    scenesSection
                    generateButton
                }
                .padding()
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            Text("Create Your Story")
                .font(.headline)
            
            Spacer()
            
            Button(action: { showingFormatGuide = true }) {
                Label("Format Guide", systemImage: "book.fill")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    private var sceneProgressSection: some View {
        VStack(spacing: 12) {
            SceneCounter(currentCount: currentSceneCount, maxScenes: maxScenes)
            
            if currentSceneCount >= maxScenes {
                Text("Maximum scenes reached")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var characterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Main Character")
                .font(.headline)
            
            Text(book.character.description)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
        }
    }
    
    private var formatGuideSection: some View {
        DisclosureGroup(
            isExpanded: $showGuideSection,
            content: {
                QuickFormatGuideView()
            },
            label: {
                Label("Format Guide", systemImage: "list.bullet.rectangle")
                    .font(.headline)
            }
        )
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var scenesSection: some View {
        VStack(spacing: 16) {
            ForEach(0..<maxScenes, id: \.self) { index in
                SceneInputCard(
                    sceneNumber: index + 1,
                    content: $sceneTexts[index],
                    hideCharacter: $hideCharacterFlags[index],
                    isActive: index == currentSceneIndex,
                    isValid: isValidScene(sceneTexts[index])
                )
                .onChange(of: sceneTexts[index]) { _ in
                    if isValidScene(sceneTexts[index]) && index < maxScenes - 1 {
                        currentSceneIndex = index + 1
                    }
                }
            }
        }
    }
    
    private var generateButton: some View {
        Button(action: generateStory) {
            HStack {
                Text(isGenerating ? "Creating Your Story..." : "Generate Visual Story")
                if isGenerating {
                    ProgressView()
                        .tint(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isValidForGeneration ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(!isValidForGeneration || isGenerating)
    }
    
    private var isValidForGeneration: Bool {
        
        currentSceneCount > 0 &&
        sceneTexts.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
    
    private func isValidScene(_ scene: String) -> Bool {
        let trimmed = scene.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return !trimmed.isEmpty // Sadece boş olmamasını kontrol edelim
    }
    
    // StoryPageCreationView içinde:
    private func formatScenesToPrompt(scenes: [(description: String, hideCharacter: Bool)]) -> String {
        return scenes.map { scene in
            let prefix = scene.hideCharacter ? "[NC] " : ""
            return "\(prefix)\(scene.description)"
        }.joined(separator: "\n")
    }

    @MainActor
    private func generateStory() {
       Task {
           isGenerating = true
           defer { isGenerating = false }
           
           do {
               guard let image = try await viewModel.generateStoryImage(
                   sceneTexts: sceneTexts,
                   hideCharacterFlags: hideCharacterFlags
               ) else {
                   throw StoryGenerationError.imageGenerationFailed
               }
               
               generatedImages.append(image)
               let validScenes = zip(sceneTexts, hideCharacterFlags)
                   .filter { !$0.0.isEmpty }
                   .map { $0.0 }
               
           } catch {
               // Hata işleme eklenebilir
              // errorMessage = error.localizedDescription
               print("Story generation error: \(error)")
           }
       }
    }
    // MARK: - Supporting Views
    struct SceneInputCard: View {
        let sceneNumber: Int
        @Binding var content: String
        @Binding var hideCharacter: Bool
        let isActive: Bool
        let isValid: Bool
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Text("Scene \(sceneNumber)")
                        .font(.headline)
                    
                    Spacer()
                    
                    // Improved hide character button
                    Button(action: { hideCharacter.toggle() }) {
                        HStack(spacing: 4) {
                            Image(systemName: hideCharacter ? "person.slash.fill" : "person.fill")
                            Text(hideCharacter ? "Scene without character" : "Scene with character")
                                .font(.caption)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(hideCharacter ? Color.orange.opacity(0.2) : Color.blue.opacity(0.2))
                        .foregroundColor(hideCharacter ? .orange : .blue)
                        .cornerRadius(8)
                    }
                }
                
                // Scene Description
                VStack(alignment: .leading, spacing: 8) {
                    TextEditor(text: $content)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(strokeColor, lineWidth: 1)
                        )
                        .overlay(
                            Group {
                                if content.isEmpty {
                                    Text(placeholderText)
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                }
                            },
                            alignment: .topLeading
                        )
                    
                    if isActive {
                        Text("Tell us where, what's happening, and when")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
        }
        
        private var placeholderText: String {
            if hideCharacter {
                return "Describe a scene without the main character...\nFor example: empty garden, flowers swaying in the wind, peaceful morning"
            } else {
                return "Describe your scene here...\nFor example: in the garden, planting flowers, sunny morning"
            }
        }
        
        private var strokeColor: Color {
            if content.isEmpty { return .gray }
            return isValid ? .green : .orange
        }
        
        private var backgroundColor: Color {
            isActive ? Color.blue.opacity(0.1) : Color.secondary.opacity(0.1)
        }
    }
    
    struct SceneCounter: View {
        var currentCount: Int
        var maxScenes: Int
        
        var body: some View {
            VStack(spacing: 8) {
                HStack(spacing: 16) {
                    ForEach(0..<maxScenes, id: \.self) { index in
                        Circle()
                            .fill(index < currentCount ? Color.blue : Color.gray)
                            .frame(width: 12, height: 12)
                    }
                }
                
                Text("\(currentCount)/\(maxScenes) Scenes")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    struct QuickFormatGuideView: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                formatExample(
                    title: "How to Write Your Scene",
                    examples: [
                        "First, describe where: in the garden, at school",
                        "Then, what's happening: reading a book, playing with friends",
                        "Add when/how: sunny morning, quiet afternoon"
                    ]
                )
                
                formatExample(
                    title: "Example Scenes",
                    examples: [
                        "in the garden, planting colorful flowers, sunny morning",
                        "at the library, reading a magical book, quiet afternoon",
                        "in the park, playing with friends, beautiful evening"
                    ]
                )
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tips:")
                        .font(.subheadline)
                        .bold()
                    
                    tipItem("Be specific about the place and action")
                    tipItem("Add time of day or mood to make it more vivid")
                    tipItem("Keep it simple and clear")
                }
            }
        }
        
        private func formatExample(title: String, examples: [String]) -> some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .bold()
                
                ForEach(examples, id: \.self) { example in
                    Text(example)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        
        private func tipItem(_ text: String) -> some View {
            Label(
                title: { Text(text).font(.caption) },
                icon: { Image(systemName: "checkmark.circle.fill").foregroundColor(.green) }
            )
        }
    }
    
    
    struct StoryDiffusionRequest: CustomStringConvertible {
        let bookInfo: BookInfo
        let storySetup: StorySetupInfo
        let character: CharacterInfo
        let scenes: [SceneInfo]
        
        struct BookInfo {
            let title: String
            let ageGroup: AgeGroup
            let description: String
            let tags: [String]
        }
        
        struct StorySetupInfo {
            let setting: String
            let timeOfDay: String
            let mood: String
            let theme: String
        }
        
        struct CharacterInfo {
            let description: String
            let traits: [String]
            let style: String
            let age: String
            let gender: String
            let occupation: String
        }
        
        struct SceneInfo {
            let description: String
            let hideCharacter: Bool
        }
        
        var description: String {
            """
            📚 Story Diffusion Request
            ---------------------------
            📖 Book Info:
            - Title: \(bookInfo.title)
            - Age Group: \(bookInfo.ageGroup.rawValue)
            - Description: \(bookInfo.description)
            - Tags: \(bookInfo.tags.joined(separator: ", "))
            
            🎬 Story Setup:
            - Setting: \(storySetup.setting)
            - Time of Day: \(storySetup.timeOfDay)
            - Mood: \(storySetup.mood)
            - Theme: \(storySetup.theme)
            
            👤 Character:
            - Description: \(character.description)
            - Traits: \(character.traits.joined(separator: ", "))
            - Style: \(character.style)
            - Age: \(character.age)
            - Gender: \(character.gender)
            - Occupation: \(character.occupation)
            
            📑 Scenes:
            \(scenes.enumerated().map { index, scene in
                """
                Scene \(index + 1):
                - Description: \(scene.description)
                - Hide Character: \(scene.hideCharacter)
                """
            }.joined(separator: "\n"))
            """
        }
    }
}
enum StoryGenerationError: Error {
   case imageGenerationFailed
}
