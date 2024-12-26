import SwiftUI

enum FieldState {
    case empty
    case invalid
    case valid
}

struct FormProgressBar: View {
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(Int(progress * 100))% Completed")
                .font(.caption)
                .foregroundColor(.gray)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.2))
                        .cornerRadius(8)
                    
                    Rectangle()
                        .frame(width: geometry.size.width * progress)
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                        .animation(.spring(), value: progress)
                }
            }
            .frame(height: 8)
        }
    }
}

struct ValidationIndicator: View {
    let fieldState: FieldState
    let message: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
            
            Text(message)
                .font(.caption)
                .foregroundColor(color)
        }
        .animation(.easeInOut, value: fieldState)
    }
    
    private var icon: String {
        switch fieldState {
        case .empty: return "circle"
        case .invalid: return "exclamationmark.circle.fill"
        case .valid: return "checkmark.circle.fill"
        }
    }
    
    private var color: Color {
        switch fieldState {
        case .empty: return .gray
        case .invalid: return .red
        case .valid: return .green
        }
    }
}

struct BookInfoForm: View {
    @Binding var book: Book
    @State private var showingTagInput = false
    @State private var newTag = ""
    @FocusState private var focusedField: Field?
    @State private var fieldStates: [String: FieldState] = [:]
    @State private var showingTooltip: String?
    private func calculateProgress() -> Double {
            var total = 0.0
            var completed = 0.0
            
            // Title (30%)
            total += 0.3
            if book.isTitleValid { completed += 0.3 }
            
            // Description (40%)
            total += 0.4
            if book.isDescriptionValid { completed += 0.4 }
            
            // Age Group (30%)
            total += 0.3
            if book.isAgeGroupValid { completed += 0.3 }
            
            return total > 0 ? completed / total : 0
        }
   
    
    enum Field {
        case title, description
    }
    
    private let popularTags = [
        "Adventure", "Mystery", "Fantasy", "Romance",
        "Science Fiction", "Horror", "Comedy", "Drama",
        "Action", "Thriller"
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Progress Bar
                FormProgressBar(progress: book.calculateProgress())
                    .padding(.bottom)
                
                // Title Input
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Title")
                            .font(.headline)
                            .foregroundColor(.primary.opacity(0.8))
                        
                        Button(action: { showingTooltip = "title" }) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    TextField("Enter your story title", text: $book.title)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .focused($focusedField, equals: .title)
                        .onChange(of: book.title) { newValue in
                            withAnimation {
                                updateFieldState("title")
                            }
                        }
                    
                    if let titleState = fieldStates["title"] {
                        ValidationIndicator(
                            fieldState: titleState,
                            message: validationMessage(for: titleState, field: "title")
                        )
                    }
                }
                
                // Age Group Selection
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Age Group")
                            .font(.headline)
                            .foregroundColor(.primary.opacity(0.8))
                        
                        Button(action: { showingTooltip = "ageGroup" }) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 100), spacing: 12)
                    ], spacing: 12) {
                        ForEach(AgeGroup.allCases, id: \.self) { age in
                            EnhancedAgeGroupButton(
                                age: age,
                                isSelected: book.ageGroup == age,
                                action: {
                                    withAnimation {
                                        book.ageGroup = age
                                        updateFieldState("ageGroup")
                                    }
                                }
                            )
                        }
                    }
                    
                    if let ageState = fieldStates["ageGroup"] {
                        ValidationIndicator(
                            fieldState: ageState,
                            message: validationMessage(for: ageState, field: "ageGroup")
                        )
                    }
                }
                
                // Description Input
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Description")
                            .font(.headline)
                            .foregroundColor(.primary.opacity(0.8))
                        
                        Button(action: { showingTooltip = "description" }) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    TextEditor(text: $book.description)
                        .frame(minHeight: 100)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .focused($focusedField, equals: .description)
                        .onChange(of: book.description) { _ in
                            withAnimation {
                                updateFieldState("description")
                            }
                        }
                    
                    HStack {
                        if let descriptionState = fieldStates["description"] {
                            ValidationIndicator(
                                fieldState: descriptionState,
                                message: validationMessage(for: descriptionState, field: "description")
                            )
                        }
                        
                        Spacer()
                        
                        Text("\(book.description.count)/200")
                            .font(.caption)
                            .foregroundColor(
                                book.description.count > 200 ? .red : .gray
                            )
                    }
                }
                // Tags Section
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Tags")
                                            .font(.headline)
                                            .foregroundColor(.primary.opacity(0.8))
                                        
                                        Text("(Optional)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                        Button(action: { showingTooltip = "tags" }) {
                                            Image(systemName: "info.circle")
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        Text("\(book.tags.count)/5 tags")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    // Popular Tags Section
                                    if book.tags.isEmpty {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Suggested Tags")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                            
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 8) {
                                                    ForEach(popularTags, id: \.self) { tag in
                                                        SuggestedTagButton(tag: tag) {
                                                            if book.tags.count < 5 {
                                                                withAnimation {
                                                                    book.tags.append(tag)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Tags Cloud
                                    FlowLayout(spacing: 8) {
                                        ForEach(book.tags, id: \.self) { tag in
                                            TagView(tag: tag) {
                                                withAnimation {
                                                    book.tags.removeAll { $0 == tag }
                                                }
                                            }
                                        }
                                        
                                        // Add Tag Button
                                        if !showingTagInput && book.tags.count < 5 {
                                            AddTagButton {
                                                withAnimation {
                                                    showingTagInput = true
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Tag Input Field
                                    if showingTagInput {
                                        HStack {
                                            TextField("Enter tag", text: $newTag)
                                                .textFieldStyle(.plain)
                                                .padding()
                                                .background(Color.gray.opacity(0.1))
                                                .cornerRadius(12)
                                                .submitLabel(.done)
                                                .onSubmit {
                                                    addTag()
                                                }
                                            
                                            Button("Add") {
                                                addTag()
                                            }
                                            .buttonStyle(.bordered)
                                            .disabled(newTag.isEmpty || book.tags.count >= 5)
                                        }
                                    }
                                }
                                
                                // Privacy Toggle
                                VStack(spacing: 16) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text("Privacy")
                                                    .font(.headline)
                                                    .foregroundColor(.primary.opacity(0.8))
                                                
                                                Button(action: { showingTooltip = "privacy" }) {
                                                    Image(systemName: "info.circle")
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                            
                                            Text("Make this story private")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        Toggle("", isOn: $book.isPrivate)
                                            .labelsHidden()
                                    }
                                    
                                    // Privacy Info
                                    if book.isPrivate {
                                        HStack(spacing: 8) {
                                            Image(systemName: "lock.fill")
                                                .foregroundColor(.blue)
                                            
                                            Text("Only you can see this story")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            }
                            .padding()
                            .onAppear {
                                updateFieldState("title")
                                updateFieldState("description")
                                updateFieldState("ageGroup")
                            }
                        }
                    }
                    
                    private func updateFieldState(_ field: String) {
                        switch field {
                        case "title":
                            if book.title.isEmpty {
                                fieldStates[field] = .empty
                            } else if book.isTitleValid {
                                fieldStates[field] = .valid
                            } else {
                                fieldStates[field] = .invalid
                            }
                            
                        case "description":
                            if book.description.isEmpty {
                                fieldStates[field] = .empty
                            } else if book.isDescriptionValid {
                                fieldStates[field] = .valid
                            } else {
                                fieldStates[field] = .invalid
                            }
                            
                        case "ageGroup":
                            fieldStates[field] = book.isAgeGroupValid ? .valid : .empty
                            
                        default:
                            break
                        }
                    }
                    
                    private func validationMessage(for state: FieldState, field: String) -> String {
                        switch (state, field) {
                        case (.empty, "title"):
                            return "Title is required"
                        case (.invalid, "title"):
                            return "Title should be between 3-50 characters"
                        case (.valid, "title"):
                            return "Perfect title length!"
                            
                        case (.empty, "description"):
                            return "Description is required"
                        case (.invalid, "description"):
                            return "Description should be between 10-200 characters"
                        case (.valid, "description"):
                            return "Great description!"
                            
                        case (.empty, "ageGroup"):
                            return "Please select an age group"
                        case (.valid, "ageGroup"):
                            return "Age group selected!"
                            
                        default:
                            return ""
                        }
                    }
                    
                    private func tooltipText(for field: String) -> String {
                        switch field {
                        case "title":
                            return "Choose a captivating title between 3-50 characters"
                        case "description":
                            return "Describe your story in 10-200 characters"
                        case "ageGroup":
                            return "Select the appropriate age group for your story"
                        case "tags":
                            return "Add up to 5 tags to help others find your story"
                        case "privacy":
                            return "Private stories are only visible to you"
                        default:
                            return ""
                        }
                    }
                    
                    private func addTag() {
                        if !newTag.isEmpty && book.tags.count < 5 {
                            withAnimation {
                                book.tags.append(newTag)
                                newTag = ""
                                showingTagInput = false
                            }
                        }
                    }
                }

                struct EnhancedAgeGroupButton: View {
                    let age: AgeGroup
                    let isSelected: Bool
                    let action: () -> Void
                    
                    var body: some View {
                        Button(action: action) {
                            VStack(spacing: 8) {
                                Image(systemName: iconName(for: age))
                                    .font(.system(size: 24))
                                
                                Text(age.rawValue)
                                    .font(.subheadline)
                                
                                Text(ageRange(for: age))
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
                            .foregroundColor(isSelected ? .white : .primary)
                            .cornerRadius(12)
                        }
                    }
                    
                    private func iconName(for age: AgeGroup) -> String {
                        switch age {
                        case .children: return "face.smiling"
                        case .youngAdult: return "person.2"
                        case .adult: return "person.3"
                        }
                    }
                    
                    private func ageRange(for age: AgeGroup) -> String {
                        switch age {
                        case .children: return "5-12 years"
                        case .youngAdult: return "13-17 years"
                        case .adult: return "18+ years"
                        }
                    }
                }

                struct SuggestedTagButton: View {
                    let tag: String
                    let action: () -> Void
                    
                    var body: some View {
                        Button(action: action) {
                            HStack(spacing: 4) {
                                Text(tag)
                                                    .font(.subheadline)
                                                
                                                Image(systemName: "plus.circle.fill")
                                                    .font(.system(size: 12))
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.gray.opacity(0.1))
                                            .foregroundColor(.primary)
                                            .cornerRadius(16)
                                        }
                                    }
                                }

                                struct TagView: View {
                                    let tag: String
                                    let onDelete: () -> Void
                                    
                                    var body: some View {
                                        HStack(spacing: 4) {
                                            Text(tag)
                                                .font(.subheadline)
                                            
                                            Button(action: onDelete) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: 12))
                                            }
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(16)
                                    }
                                }

                                struct AddTagButton: View {
                                    let action: () -> Void
                                    
                                    var body: some View {
                                        Button(action: action) {
                                            HStack {
                                                Image(systemName: "plus.circle.fill")
                                                Text("Add Tag")
                                            }
                                            .font(.subheadline)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.blue.opacity(0.1))
                                            .foregroundColor(.blue)
                                            .cornerRadius(16)
                                        }
                                    }
                                }

                                struct FlowLayout: Layout {
                                    var spacing: CGFloat = 8
                                    
                                    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
                                        let runs = computeRuns(proposal: proposal, subviews: subviews)
                                        return CGSize(
                                            width: proposal.width ?? .infinity,
                                            height: runs.reduce(0) { $0 + $1.height } + spacing * CGFloat(runs.count - 1)
                                        )
                                    }
                                    
                                    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
                                        let runs = computeRuns(proposal: proposal, subviews: subviews)
                                        
                                        var y = bounds.minY
                                        for run in runs {
                                            var x = bounds.minX
                                            for subview in run.views {
                                                subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                                                x += subview.sizeThatFits(.unspecified).width + spacing
                                            }
                                            y += run.height + spacing
                                        }
                                    }
                                    
                                    private func computeRuns(proposal: ProposedViewSize, subviews: Subviews) -> [Run] {
                                        var runs: [Run] = []
                                        var currentRun = Run(views: [], height: 0)
                                        var x: CGFloat = 0
                                        
                                        for subview in subviews {
                                            let size = subview.sizeThatFits(.unspecified)
                                            
                                            if x + size.width > (proposal.width ?? .infinity) {
                                                runs.append(currentRun)
                                                currentRun = Run(views: [], height: 0)
                                                x = size.width + spacing
                                                currentRun.views.append(subview)
                                                currentRun.height = size.height
                                            } else {
                                                x += size.width + spacing
                                                currentRun.views.append(subview)
                                                currentRun.height = max(currentRun.height, size.height)
                                            }
                                        }
                                        
                                        if !currentRun.views.isEmpty {
                                            runs.append(currentRun)
                                        }
                                        
                                        return runs
                                    }
                                    
                                    struct Run {
                                        var views: [LayoutSubview]
                                        var height: CGFloat
                                    }
                                }

                                // Preview için helper extension
//                                extension Book {
//                                    static var preview: Book {
////                                        Book(
////                                            title: "Sample Book",
////                                            description: "A sample book description for preview purposes",
////                                            ageGroup: .youngAdult,
////                                            tags: ["Fantasy", "Adventure"],
////                                            isPrivate: false
////                                        )
//                                    }
//                                }

//                                // Preview provider
//                                struct BookInfoForm_Previews: PreviewProvider {
//                                    static var previews: some View {
//                                        BookInfoForm(book: .constant(.preview))
//                                    }
//                                }
