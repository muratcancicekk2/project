import SwiftUI



// MARK: - StorySetup Validation
extension StorySetup {
    var isValid: Bool {
        !setting.isEmpty && !timeOfDay.isEmpty && !mood.isEmpty && !theme.isEmpty
    }
}

