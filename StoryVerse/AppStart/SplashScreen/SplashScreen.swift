import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            LoginView()  // AuthenticationView yerine LoginView'a yönlendiriyoruz
        } else {
            ZStack {
                Color("backgroundColor") // Asset'te tanımlayabiliriz veya direkt renk kullanabiliriz
                    .ignoresSafeArea()
                
                VStack {
                    VStack(spacing: 20) {
                        Image(systemName: "paintbrush.fill") // Geçici olarak system icon kullanıyoruz
                            .font(.system(size: 80))
                            .foregroundColor(.accentColor)
                        
                        Text("Story Verse")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Karikatürünü Oluştur")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .scaleEffect(size)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.2)) {
                            self.size = 0.9
                            self.opacity = 1.0
                        }
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreen()
}
