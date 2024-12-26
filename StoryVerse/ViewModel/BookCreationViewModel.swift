import SwiftUI
import FirebaseFirestore

// Main book model that will be saved to Firebase
struct Book: Codable, Identifiable {
    let id: String
    var title: String
    var ageGroup: AgeGroup
    var description: String
    var coverImage: String? // URL or Base64
    var storySetup: StorySetup
    var character: Character
    var pages: [Page]
    var isPrivate: Bool
    var createdAt: Date
    var updatedAt: Date
    var tags: [String]
    
    init(id: String = UUID().uuidString) {
        self.id = id
        self.title = ""
        self.ageGroup = .adult
        self.description = ""
        self.coverImage = nil
        self.storySetup = StorySetup()
        self.character = Character()
        self.pages = []
        self.isPrivate = false
        self.createdAt = Date()
        self.updatedAt = Date()
        self.tags = []
    }
    
    // Validation helpers
     var isTitleValid: Bool {
         title.count >= 3 && title.count <= 50
     }
     
     var isDescriptionValid: Bool {
         description.count >= 10 && description.count <= 200
     }
     
     var isAgeGroupValid: Bool {
         ageGroup != nil
     }
     
     // Form progress calculation
     func calculateProgress() -> Double {
         var total = 0.0
         var completed = 0.0
         
         // Title (30%)
         total += 0.3
         if isTitleValid { completed += 0.3 }
         
         // Description (40%)
         total += 0.4
         if isDescriptionValid { completed += 0.4 }
         
         // Age Group (30%)
         total += 0.3
         if isAgeGroupValid { completed += 0.3 }
         
         return total > 0 ? completed / total : 0
     }
}

// Supporting models
struct StorySetup: Codable {
    var setting: String = ""
    var timeOfDay: String = ""
    var mood: String = ""
    var theme: String = ""
}
// 1. Character Model
struct Character: Codable {
    var description: String = ""
    var traits: [String] = []
    var style: String = ""
    var age: String = ""
    var gender: String = ""
    var occupation: String = ""
    
    var isValid: Bool {
        !description.isEmpty && !traits.isEmpty && !style.isEmpty
    }
}

// 2. Örnek Karakter Modeli
struct CharacterExample: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let traits: [String]
    let description: String
}
struct Page: Codable, Identifiable {
    let id: String
    var description: String
    var generatedImage: String? // URL or Base64
    var pageNumber: Int
    
    init(id: String = UUID().uuidString, description: String = "", pageNumber: Int) {
        self.id = id
        self.description = description
        self.generatedImage = nil
        self.pageNumber = pageNumber
    }
}

enum BookCreationStep: String, CaseIterable {
    case bookInfo          // Book name, age group selection
    case coverImage        // Cover image
    case storySetup        // Main story setup
    case characterCreation // Character details
    case pageCreation     // Page by page story creation
}

enum AgeGroup: String, CaseIterable, Codable {
    case children = "Children"
    case youngAdult = "Young Adult"
    case adult = "Adult"
}

// View Model for managing book creation state
class BookCreationViewModel: ObservableObject {
    @Published var book: Book
    @Published var currentStep: BookCreationStep = .bookInfo
    @Published var isLoading = false
    @Published var error: Error?
    private let storyService: StoryDiffusionServiceProtocol

    init(book: Book = Book(), storyService: StoryDiffusionServiceProtocol = StoryDiffusionService(apiKey: "SG_2ee8a9d0588b57b2")) {
         self.book = book
         self.storyService = storyService
     }
    
    @MainActor
    func generateStoryImage(sceneTexts: [String], hideCharacterFlags: [Bool]) async throws -> UIImage? {
       isLoading = true
       defer { isLoading = false }
       
       let validScenes = zip(sceneTexts, hideCharacterFlags)
           .filter { !$0.0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
           .map { (description: $0.0, hideCharacter: $0.1) }
       
       guard !validScenes.isEmpty else {
           throw NSError(domain: "StoryGeneration", code: -1, userInfo: [NSLocalizedDescriptionKey: "No valid scenes provided"])
       }
           
       let request = StoryDiffusionAPIRequest(
           numIds: validScenes.count,
           characterDescription: book.character.description,
           comicDescription: formatScenesToPrompt(scenes: validScenes).components(separatedBy: "#").joined(separator: "\n"),  // # yerine \n kullan
           styleName: book.character.style
       )
       
       return try await storyService.generateStory(request: request)
    }
       
    private func formatScenesToPrompt(scenes: [(description: String, hideCharacter: Bool)]) -> String {
        return scenes.map { scene in
            let prefix = scene.hideCharacter ? "[NC] " : ""
            let theme = book.storySetup.theme.isEmpty ? "" : ", theme: \(book.storySetup.theme)"
            let mood = book.storySetup.mood.isEmpty ? "" : ", mood: \(book.storySetup.mood)"
            let time = book.storySetup.timeOfDay.isEmpty ? "" : ", time: \(book.storySetup.timeOfDay)"
            let setting = book.storySetup.setting.isEmpty ? "" : ", in \(book.storySetup.setting)"
            let traits = book.character.traits.isEmpty ? "" : ", character traits: \(book.character.traits.joined(separator: ", "))"
            
            return "\(prefix)\(scene.description)\(setting)\(theme)\(mood)\(time)\(traits)"
        }.joined(separator: "\n")
    }
       
    
       
    
    func validateCurrentStep() -> Bool {
        switch currentStep {
        case .bookInfo:
            return book.isTitleValid && book.isDescriptionValid && book.isAgeGroupValid
        case .coverImage:
            return true // Optional olabilir
        case .storySetup:
            return book.storySetup.isValid
        case .characterCreation:
            return book.character.isValid
        case .pageCreation:
            return !book.pages.isEmpty
        }
    }
    func moveToNextStep() {
        guard validateCurrentStep() else { return }
        
        withAnimation {
            switch currentStep {
            case .bookInfo: currentStep = .coverImage
            case .coverImage: currentStep = .storySetup
            case .storySetup: currentStep = .characterCreation
            case .characterCreation: currentStep = .pageCreation
            case .pageCreation: break
            }
        }
    }
    
    func moveToPreviousStep() {
        withAnimation {
            switch currentStep {
            case .bookInfo: break // First step, do nothing
            case .coverImage: currentStep = .bookInfo
            case .storySetup: currentStep = .coverImage
            case .characterCreation: currentStep = .storySetup
            case .pageCreation: currentStep = .characterCreation
            }
        }
    }
}
