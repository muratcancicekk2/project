import SwiftUI

enum HomeNavigation {
    case createBook
    case continueBook
    case quickScene
}

struct HomeView: View {
    @State private var navigation: HomeNavigation?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                // Logo/Title Area
                VStack(spacing: 16) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Story Creator")
                        .font(.title)
                        .bold()
                }
                .padding(.top, 60)
                
                // Main Buttons
                VStack(spacing: 20) {
                    // Create New Book Button
                    NavigationLink(value: HomeNavigation.createBook) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("Create New Book")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    // Continue Book Button
                    NavigationLink(value: HomeNavigation.continueBook) {
                        HStack {
                            Image(systemName: "book.fill")
                                .font(.title2)
                            Text("Continue Book")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                    
                    // Quick Scene Generation Button
                    NavigationLink(value: HomeNavigation.quickScene) {
                        HStack {
                            Image(systemName: "wand.and.stars")
                                .font(.title2)
                            Text("Create Scene")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .navigationDestination(for: HomeNavigation.self) { navigation in
                switch navigation {
                case .createBook:
                    Text("Continue Book View")
                case .continueBook:
                    Text("Continue Book View")
                case .quickScene:
                    Text("Quick Scene Generation View")
                }
            }
        }
    }
}

// Preview Provider
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
