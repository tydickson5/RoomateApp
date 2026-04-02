//
//  ContentView.swift
//  RoomateApp
//
//  Created by Ty Dickson on 1/23/26.
//

import SwiftUI
import FirebaseFirestore

struct ContentView: View {
    
    
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var groupManager: GroupManager
    @EnvironmentObject var itemManager: ItemManager
    
    
    var body: some View {
        
        Group{
            
            
            
            if authManager.isLoading {
                // Show loading screen while checking auth state
                VStack {
                    ProgressView()
                    Text("Loading...")
                        .padding(.top)
                }
            } else if authManager.isAuthenticated, authManager.user != nil {
                // User is authenticated AND user data is loaded
                
                
                
                
                
                
                TabView{
                    IndividualListView().id(authManager.user?.userID ?? "loggedOut")
                        .tabItem { Label("Your List", systemImage: "house.fill") }
                    GroupView()
                        .tabItem { Label("Groups",
                            systemImage: "person.2.fill")}
                    AccountView()
                        .tabItem { Label("Profile", systemImage: "person.fill") }
                }
                .tint(Color.main)
                
                

        } else if authManager.isAuthenticated {
                // Authenticated but user data not loaded yet
                VStack {
                    ProgressView()
                    Text("Loading user data...")
                        .padding(.top)
                }
            } else {
                // Not authenticated - show login
                LoginView()
            }
        }
        .task(id: authManager.user?.id) {
                if let user = authManager.user {
                    await groupManager.getUserGroups(user: user)
                    print(groupManager.groups)
                    await groupManager.loadOrCreateIndividualGroup(user: user)
                }
            }
        .onOpenURL { url in
            Task{
                print("Url = \(url)")
                
                guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                    return
                }

                if components.path == "/join" {
                    let groupId = components.queryItems?
                        .first(where: { $0.name == "groupId" })?.value

                    if let groupId = groupId {
                        print("Group ID:", groupId)
                        
                        // Wait for auth + user data to be ready before proceeding
                        var attempts = 0
                        while authManager.isLoading || authManager.user == nil {
                            guard attempts < 50 else { return } // timeout after ~2s
                            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
                            attempts += 1
                        }
                        
                        guard let user = authManager.user else { return }
                        
                        let updatedUser = await groupManager.addMemberThroughLink(groupId: groupId, user: user)
                        authManager.user = updatedUser
                    }
                
                
                }
            }
        }
    }
}

