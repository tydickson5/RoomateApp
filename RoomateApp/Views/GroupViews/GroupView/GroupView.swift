//
//  HomeView.swift
//  RoomateApp
//
//  Created by Ty Dickson on 2/3/26.
//

//
//  ContentView.swift
//  RoomateApp
//
//  Created by Ty Dickson on 1/23/26.
//

import SwiftUI
import FirebaseFirestore


struct GroupView: View {
    

    

    
    var body: some View {
        
        ItemList(type: 1)
    }
        
}



#Preview {
    GroupView()
        .environmentObject(AuthManager.preview)
}
