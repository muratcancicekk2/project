import SwiftUI

struct LoginView: View {
   @StateObject private var authManager = AuthenticationManager()
   @State private var showError = false
   @State private var errorMessage = ""
   
   var body: some View {
       VStack(spacing: 20) {
           Text("Story Verse")
               .font(.largeTitle)
               .bold()
           
           // Google Sign In Button
           Button(action: googleSignIn) {
               HStack {
                   Image(systemName: "g.circle.fill")
                       .foregroundColor(.red)
                   Text("Google ile Devam Et")
               }
               .frame(maxWidth: .infinity)
               .padding()
               .background(.white)
               .cornerRadius(10)
               .shadow(radius: 2)
           }
           
           // Apple Sign In Button
           Button(action: appleSignIn) {
               HStack {
                   Image(systemName: "apple.logo")
                   Text("Apple ile Devam Et")
               }
               .frame(maxWidth: .infinity)
               .padding()
               .background(.black)
               .foregroundColor(.white)
               .cornerRadius(10)
           }
           
           // Anonymous Sign In Button
           Button(action: anonymousSignIn) {
               Text("Anonim Olarak Devam Et")
                   .frame(maxWidth: .infinity)
                   .padding()
                   .background(.gray.opacity(0.2))
                   .cornerRadius(10)
           }
       }
       .padding()
       .alert("Hata", isPresented: $showError) {
           Button("Tamam", role: .cancel) {}
       } message: {
           Text(errorMessage)
       }
   }
   
   private func googleSignIn() {
//       Task {
//           do {
//               try await authManager.signInWithGoogle()
//               // Başarılı giriş sonrası ana sayfaya yönlendirme yapılacak
//           } catch {
//               showError = true
//               errorMessage = error.localizedDescription
//           }
//       }
   }
   
   private func appleSignIn() {
       Task {
           do {
               try await authManager.signInWithApple()
               // Başarılı giriş sonrası ana sayfaya yönlendirme yapılacak
           } catch {
               showError = true
               errorMessage = error.localizedDescription
           }
       }
   }
   
   private func anonymousSignIn() {
       Task {
           do {
               try await authManager.signInAnonymously()
               // Başarılı giriş sonrası ana sayfaya yönlendirme yapılacak
           } catch {
               showError = true
               errorMessage = error.localizedDescription
           }
       }
   }
}

#Preview {
   LoginView()
}
