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
                
                
                
                
                //check for group
                if(groupManager.groups.isEmpty){
                    AddGroupView()
                }else{
                    HomeView()
                }
                
                

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
                }
            }
    }
}

