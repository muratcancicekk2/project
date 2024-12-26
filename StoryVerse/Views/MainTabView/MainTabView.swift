import SwiftUI

enum Tab: String, CaseIterable {
    case home, profile, create, library, settings
    
    var imageName: String {
        switch self {
        case .home: return "house"
        case .profile: return "person"
        case .create: return "plus"
        case .library: return "book"
        case .settings: return "gearshape"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @State private var tabBarVisible = true
    @State private var tabBarHeight: CGFloat = 0
    
    // Theme colors
    private let primaryColor = Color.pink       // Ana renk
    private let backgroundColor = Color.black   // Arka plan rengi
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Background
                backgroundColor
                    .ignoresSafeArea()
                
                // Main content
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tag(Tab.home)
                    ProfileView()
                        .tag(Tab.profile)
                    StoryGuideView()
                        .tag(Tab.create)
                    LibraryView()
                        .tag(Tab.library)
                    SettingsView()
                        .tag(Tab.settings)
                }
                
                if !tabBarVisible {
                    HStack(spacing: 0) {
                        ForEach(Tab.allCases, id: \.self) { tab in
                            TabBarButton(imageName: tab.imageName, isSelected: false, action: {})
                                .allowsHitTesting(false)
                        }
                    }
                    .padding(8)
                    .background(Color.black)
                    .cornerRadius(25)
                    .padding(.horizontal)
                    .padding(.bottom, geometry.safeAreaInsets.bottom)
                    .opacity(0)
                }
                
                // Custom tab bar
                if tabBarVisible {
                    CustomTabBar(selectedTab: $selectedTab, tabbarVisible: $tabBarVisible)
                        .padding(.bottom, geometry.safeAreaInsets.bottom)
                        .transition(.move(edge: .bottom))
                        .background(
                            GeometryReader { geo in
                                Color.clear.onAppear {
                                    tabBarHeight = tabBarVisible ? geo.size.height : 0
                                }
                            }
                        )
                }
            }
            .background(.black)
            .ignoresSafeArea(edges: .bottom)
        }
        .environment(\.tabBarVisibility, $tabBarVisible)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    @Binding var tabbarVisible: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                TabBarButton(
                    imageName: tab.imageName,
                    isSelected: selectedTab == tab,
                    action: { selectedTab = tab }
                )
            }
        }
        .padding(8)
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -4)
        )
        .cornerRadius(25)
        .padding(.horizontal)
    }
}

struct TabBarButton: View {
    let imageName: String
    let isSelected: Bool
    let action: () -> Void
    private let primaryColor = Color.pink

    var body: some View {
        Button(action: action) {
            Image(systemName: imageName)
                .font(.system(size: 22))
                .foregroundColor(isSelected ? .white : .black.opacity(0.5))
                .frame(maxWidth: .infinity)
                .frame(height: 35)
                .padding(.vertical, 10)
                .background(isSelected ? primaryColor : Color.clear)
                .clipShape(Capsule())
        }
    }
}



struct ProfileView: View {
    var body: some View {
        Text("Profil")
    }
}

struct CreateView: View {
    var body: some View {
        Text("Oluştur")
    }
}

struct LibraryView: View {
    var body: some View {
        Text("Kitaplık")
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Ayarlar")
    }
}

// TabBarVisibilityKey
struct TabBarVisibilityKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(true)
}

extension EnvironmentValues {
    var tabBarVisibility: Binding<Bool> {
        get { self[TabBarVisibilityKey.self] }
        set { self[TabBarVisibilityKey.self] = newValue }
    }
}

#Preview {
    MainTabView()
}
