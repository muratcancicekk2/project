import Foundation
import FirebaseAuth
import AuthenticationServices
import CryptoKit
import SwiftUI

enum AuthError: Error {
    case noRootViewController
    case invalidCredential
}

class AuthenticationManager: ObservableObject {
    @Published var user: User?
    
    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }
    
    // Google Sign In with Firebase Auth
//    func signInWithGoogle() async throws {
//        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//              let window = windowScene.windows.first,
//              let rootViewController = window.rootViewController else {
//            throw AuthError.noRootViewController
//        }
//        
//        let provider = GoogleAuthProvider()
//        try await signIn(with: provider, presenting: rootViewController)
//    }
//    
//    private func signIn(with provider: AuthCredential, presenting viewController: UIViewController) async throws {
//        try await Auth.auth().signIn(with: provider)
//    }
    
    // Apple Sign In
    func signInWithApple() async throws {
        let nonce = randomNonceString()
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let result = try await performAppleSignIn(request: request)
        guard let appleIDCredential = result.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw AuthError.invalidCredential
        }
        
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce
        )
        
        try await Auth.auth().signIn(with: credential)
    }
    
    // Anonymous Sign In
    func signInAnonymously() async throws {
        try await Auth.auth().signInAnonymously()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var result = ""
        for _ in 0..<length {
            result.append("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._".randomElement()!)
        }
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        return hashString
    }
    
    private func performAppleSignIn(request: ASAuthorizationAppleIDRequest) async throws -> ASAuthorization {
        return try await withCheckedThrowingContinuation { continuation in
            let controller = ASAuthorizationController(authorizationRequests: [request])
            let delegate = SignInWithAppleDelegate(continuation: continuation)
            controller.delegate = delegate
            controller.presentationContextProvider = delegate
            controller.performRequests()
            
            // Delegate'i tutuyoruz
            objc_setAssociatedObject(controller, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

// Apple Sign In Delegate
class SignInWithAppleDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private var continuation: CheckedContinuation<ASAuthorization, Error>
    
    init(continuation: CheckedContinuation<ASAuthorization, Error>) {
        self.continuation = continuation
        super.init()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window found")
        }
        return window
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        continuation.resume(returning: authorization)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation.resume(throwing: error)
    }
}
