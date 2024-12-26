import SwiftUI
import Combine
import PhotosUI
import FirebaseFirestore

struct StoryGuideView: View {
    @StateObject private var viewModel = BookCreationViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingHelpTip = false
    @State private var showingExitAlert = false
    
    private let stepHints = [
        "bookInfo": "Define the main theme of your story and target age group",
        "coverImage": "Choose a cover that best represents your story",
        "storySetup": "Describe the setting and time of your story",
        "characterCreation": "Describe your character in detail. Example: 'a young woman wearing a purple sweater and jeans, with a camera around her neck'",
        "pageCreation": "Describe each scene in detail. Example: 'at home, looking at old photos on the wall #at home, discovers an old map behind a family photo'"
    ]
    
    private var stepTitle: String {
        switch viewModel.currentStep {
        case .bookInfo: return "Book Information"
        case .coverImage: return "Cover Image"
        case .storySetup: return "Story Setup"
        case .characterCreation: return "Character Creation"
        case .pageCreation: return "Page Creation"
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Navigation Bar
                customNavigationBar
                    .background(.ultraThinMaterial)
                
                // Progress Steps
                StepProgressView(currentStep: viewModel.currentStep)
                    .padding(.vertical)
                
                // Main Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Step Header
                        stepHeader
                        
                        // Help Tip
                        if showingHelpTip {
                            TipView(text: stepHints[viewModel.currentStep.rawValue] ?? "")
                                .transition(.moveAndFade)
                        }
                        
                        // Step Content
                        stepContent
                            .transition(.opacity)
                    }
                    .padding()
                }
                
                // Bottom Navigation
                bottomNavigation
            }
            
            // Loading Overlay
            if viewModel.isLoading {
                ProgressView()
                    .background(Color.black.opacity(0.4))
                    .ignoresSafeArea()
            }
        }
        .navigationBarHidden(true)
        .alert("Exit Book Creation?", isPresented: $showingExitAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Exit", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Your progress will not be saved.")
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") { viewModel.error = nil }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "")
        }
    }
    
    private var customNavigationBar: some View {
        HStack {
            // Back Button
            Button(action: {
                showingExitAlert = true
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // Title
            Text("Create Story")
                .font(.headline)
            
            Spacer()
            
            // Help Button
            Button(action: {
                withAnimation(.spring()) {
                    showingHelpTip.toggle()
                }
            }) {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding()
    }
    
    private var stepHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(stepTitle)
                .font(.title2)
                .bold()
            
            Text(stepHints[viewModel.currentStep.rawValue] ?? "")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
    private var stepContent: some View {
        VStack {
            switch viewModel.currentStep {
            case .bookInfo:
                BookInfoForm(book: $viewModel.book)
            case .coverImage:
                CoverImageSelector(book: $viewModel.book)
            case .storySetup:
                StorySetupForm(setup: $viewModel.book.storySetup)
            case .characterCreation:
                CharacterCreationForm(character: $viewModel.book.character)
            case .pageCreation:
                StoryPageCreationView(book: $viewModel.book, viewModel: viewModel)
            default:
                EmptyView()
            }
        }
    }
    
    private var bottomNavigation: some View {
        HStack {
            // Back Button
            Button(action: {
                withAnimation {
                    viewModel.moveToPreviousStep()
                }
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .frame(width: 100)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            .disabled(viewModel.currentStep == .bookInfo)
            
            Spacer()
            
            // Next/Finish Button
            Button(action: {
                if viewModel.currentStep == .pageCreation {
                 
                } else {
                    viewModel.moveToNextStep()
                }
            }) {
                HStack {
                    Text(viewModel.currentStep == .pageCreation ? "Finish" : "Next")
                    Image(systemName: "chevron.right")
                }
                .frame(width: 100)
                .padding()
                .background(viewModel.validateCurrentStep() ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(!viewModel.validateCurrentStep())
        }
        .padding()
    }
}

struct StepProgressView: View {
    let currentStep: BookCreationStep
    
    private let steps: [BookCreationStep] = [
        .bookInfo, .coverImage, .storySetup,
        .characterCreation, .pageCreation
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(steps, id: \.self) { step in
                let isActive = steps.firstIndex(of: step)! <=
                    steps.firstIndex(of: currentStep)!
                
                Circle()
                    .fill(isActive ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 10, height: 10)
                
                if step != steps.last {
                    Rectangle()
                        .fill(isActive ? Color.blue : Color.gray.opacity(0.3))
                        .frame(height: 2)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct TipView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
    }
}

extension AnyTransition {
    static var moveAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        )
    }
}
