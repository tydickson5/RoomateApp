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
    
    
    var body: some View {
        
        if authManager.isAuthenticated {
            HomeView()
        } else {
            LoginView()
        }
    }
}

