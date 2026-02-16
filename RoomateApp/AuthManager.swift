//
//  AuthManager.swift
//  RoomateApp
//
//  Created by Ty Dickson on 1/27/26.
//

import Firebase
import FirebaseAuth
import Foundation
import CryptoKit
import GoogleSignIn
import AuthenticationServices
import FirebaseCore


@MainActor
class AuthManager: ObservableObject{
    
    @Published var user: User?
    @Published var isAuthenticated: Bool = false
    @Published var firebaseUser: FirebaseAuth.User?
    private let db = Firestore.firestore()
    @Published var isLoading: Bool = false

    
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    
    init(){
        print("AuthManager Init")
        setupAuthListener()
    }
    
    deinit{
        if let listener = authStateListener{
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    private func setupAuthListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            Task { @MainActor in
                print("🔄 Auth state changed: \(firebaseUser?.uid ?? "nil")")
                
                if let firebaseUser = firebaseUser {
                    // User is signed in
                    self?.isAuthenticated = true
                    await self?.loadOrCreateUser(uid: firebaseUser.uid)
                } else {
                    // User is signed out
                    self?.isAuthenticated = false
                    self?.user = nil
                }
                
                self?.isLoading = false
            }
        }
    }
    
    func getUser(userid: String)async -> User? {
        let docRef = db.collection("users").document(userid)
        
        do{
            let snapshot = try await docRef.getDocument()
                
            let user = try snapshot.data(as: User.self)
            return user
        } catch {
            print("error getting user")
            return nil
        }
        
    }
    
    func changeName(newName: String){
        if(newName == ""){ return };
        db.collection("users").document(user!.userID).updateData(["name": newName])
        user?.name = newName;
        
    }
    
    private func loadOrCreateUser(uid: String) async {
        let docRef = db.collection("users").document(uid)
        
        do {
            let snapshot = try await docRef.getDocument()
            
            if snapshot.exists {
                // Use getDocument(as:) instead of manual decoding
                print("✅ Loading existing user: \(uid)")
                self.user = try snapshot.data(as: User.self)
            } else {
                // User document doesn't exist, create it
                print("➕ Creating new user: \(uid)")
                await createFirebaseUser(uid: uid)
            }
        } catch {
            print("❌ Error loading user: \(error)")
        }
    }
    
    private func createFirebaseUser(uid: String) async {
        let firebaseUser = Auth.auth().currentUser
        
        let newUser = User(
            id: uid,  // Use Firebase UID as document ID
            userID: uid,
            name: firebaseUser?.displayName ?? firebaseUser?.email ?? "User",
            groups: []
        )
        
        do {
            // Use the UID as the document ID
            try db.collection("users").document(uid).setData(from: newUser)
            self.user = newUser
            print("✅ User created successfully")
        } catch {
            print("❌ Error creating user: \(error)")
        }
    }
    
    
    
    func signUp(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
        //await userFunction(createUser: true)
    }
    
    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
        //await userFunction(createUser: false)
    }
    
    func signOut() throws {
        Task{ @MainActor in
            try Auth.auth().signOut()
            isAuthenticated = false
        }
        
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    //google sign in
    
    func signInWithGoogle()async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        
        guard let idToken = result.user.idToken?.tokenString else { return }
        let accessToken = result.user.accessToken.tokenString
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        _  = try await Auth.auth().signIn(with: credential)
        //await userFunction(createUser: authResult.additionalUserInfo?.isNewUser ?? false)
    }
    
    
    
    //Apple Sign-In
    
    func signInWithApple(authorization: ASAuthorization, nonce: String) async throws {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let appleIDToken = appleIDCredential.identityToken,
            let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            return
        }

        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )

        _ = try await Auth.auth().signIn(with: credential)
        //await userFunction(createUser: authResult.additionalUserInfo?.isNewUser ?? false)
    }

    // Helper to generate nonce for Apple Sign-In
    func createAppleSignInNonce() -> String {
        return randomNonceString()
    }

    // SHA256 hash for nonce (needed for Apple Sign-In request)
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        return hashString
    }


    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }
    
    


}



extension AuthManager {
    static var preview: AuthManager {
        let manager = AuthManager()
        
        manager.user = User(
            id: "preview-123",
            userID: "preview-123",
            name: "Preview User",
            groups: []
        )
        manager.isAuthenticated = true
        manager.isLoading = false
        return manager
    }
}
