//
//  Login.swift
//  RoomateApp
//
//  Created by Ty Dickson on 2/2/26.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    
    @EnvironmentObject var authManager: AuthManager;
    @State private var email = ""
    @State private var password = ""
    @State private var currentNonce: String?
    
    var body: some View {
        VStack(spacing: 20){
            Text("Welcome").fontWeight(.heavy)
            TextField("Email", text: $email)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.main.opacity(0.5), lineWidth: 2)
            )
            
            SecureField("Password", text: $password)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.main.opacity(0.5), lineWidth: 2)
            )
            
            Button(action: {
                Task{
                    do{
                        try await authManager.signIn(email: email, password: password)
                    } catch {
                        do{
                            try await authManager.signUp(email: email, password: password)

                        }
                        catch{
                            print(error)
                        }
                    }
                }
                
            }){
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .frame(height: 35)
                    
                    
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.main)
            
            
            
            Text("- Or -")
            
            
            SignInWithAppleButton(.signIn) { request in
                let nonce = authManager.createAppleSignInNonce()
                currentNonce = nonce
                request.requestedScopes = [.fullName, .email]
                request.nonce = authManager.sha256(nonce)
            } onCompletion: { result in
                Task {
                    switch result {
                    case .success(let authorization):
                        guard let nonce = currentNonce else {
                            print("❌ Nonce is missing!")
                            return
                        }
                        
                        do {
                            print("🍎 Calling signInWithApple...")
                            try await authManager.signInWithApple(
                                authorization: authorization,
                                nonce: nonce
                            )
                            print("✅ Apple Sign-In completed successfully!")
                        } catch {
                            print("❌ Error signing in with Apple: \(error)")
                            print("❌ Error details: \(error.localizedDescription)")
                        }
                        
                    case .failure(let error):
                        print("❌ Apple authorization failed: \(error)")
                    }
                }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            
            Button{
                Task{
                    try await authManager.signInWithGoogle()

                }
                
            } label: {
                HStack {
                    Image("google_logo")
                    Text("Sign in with Google")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color.google)
                .foregroundColor(.black)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3))
                )
            }
            
            
            

            
            
        }
        .padding()
    }
}

#Preview {
    LoginView().environmentObject(AuthManager.preview)
}
