import SwiftUI

import SwiftUI

struct StorySetupForm: View {
    @Binding var setup: StorySetup
    @State private var selectedTheme: String = ""
    
    // Örnek temalar
    private let themes = [
           "Adventure",
           "Friendship",
           "Family",
           "Nature",
           "Imagination",
           "Discovery",
           "Learning",
           "Courage"
       ]
       
       // Example times of day
       private let timesOfDay = [
           "Morning",
           "Noon",
           "Evening",
           "Night",
           "Sunset",
           "Sunrise"
       ]
       
       // Example moods
       private let moods = [
           "Cheerful",
           "Mysterious",
           "Exciting",
           "Calm",
           "Funny",
           "Emotional",
           "Thoughtful",
           "Adventurous"
       ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Hikaye Ortamı
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hikaye Nerede Geçiyor?")
                        .font(.headline)
                    
                    TextEditor(text: $setup.setting)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(
                            Group {
                                if setup.setting.isEmpty {
                                    Text("Hikayenin geçtiği yeri detaylı anlatın...")
                                        .foregroundColor(.gray)
                                        .padding(.leading, 16)
                                        .padding(.top, 16)
                                }
                            }
                        )
                    
                    Text("Örnek: Büyülü bir orman, modern bir şehir, uzay istasyonu...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Zaman Dilimi Seçimi
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hikayenin Zamanı")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(timesOfDay, id: \.self) { time in
                                timeButton(time)
                            }
                        }
                    }
                }
                
                // Atmosfer/Mood
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hikayenin Atmosferi")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(moods, id: \.self) { mood in
                                moodButton(mood)
                            }
                        }
                    }
                }
                
                // Tema Seçimi
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ana Tema")
                        .font(.headline)
                    
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 140))
                    ], spacing: 12) {
                        ForEach(themes, id: \.self) { theme in
                            themeButton(theme)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private func timeButton(_ time: String) -> some View {
        Button(action: {
            setup.timeOfDay = time
        }) {
            Text(time)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    setup.timeOfDay == time ?
                    Color.blue : Color.secondary.opacity(0.1)
                )
                .foregroundColor(
                    setup.timeOfDay == time ?
                    .white : .primary
                )
                .cornerRadius(20)
        }
    }
    
    private func moodButton(_ mood: String) -> some View {
        Button(action: {
            setup.mood = mood
        }) {
            Text(mood)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    setup.mood == mood ?
                    Color.blue : Color.secondary.opacity(0.1)
                )
                .foregroundColor(
                    setup.mood == mood ?
                    .white : .primary
                )
                .cornerRadius(20)
        }
    }
    
    private func themeButton(_ theme: String) -> some View {
        Button(action: {
            setup.theme = theme
        }) {
            Text(theme)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    setup.theme == theme ?
                    Color.blue : Color.secondary.opacity(0.1)
                )
                .foregroundColor(
                    setup.theme == theme ?
                    .white : .primary
                )
                .cornerRadius(12)
        }
    }
}

