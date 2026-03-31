//
//  GroupSettingsView.swift
//  RoomateApp
//
//  Created by Ty Dickson on 3/7/26.
//

import SwiftUI

struct GroupSettingsView: View{
    
    
    @EnvironmentObject var groupManager: GroupManager
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View{
        
        VStack(alignment: .leading, spacing: 20){
            
            ShareLink(
                item: URL(string: "https://www.chefnshare.com/join?groupId=\(groupManager.selectedGroup?.id ?? "notfound")")!,
                message: Text("Join my group on Chef n Share!")
            ) {
                HStack {
                    Text("Add member")
                        .bold()
                    Spacer()
                    Image(systemName: "square.and.arrow.up")
                        .imageScale(.large)
                }
                .padding()
                .frame(height: 45)
                .background(Color.mainTint)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            
            Text("More settings coming soon")
            
        }
        .padding()
        
    }
    
    
}
