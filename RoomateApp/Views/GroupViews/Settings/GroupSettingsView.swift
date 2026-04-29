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
    
    var type: Int;
    @Binding var anonymousNotes: Bool;
    
    var body: some View{
        
        
        
        VStack(alignment: .leading, spacing: 20){
            
            ShareLinkElement(groupId: groupManager.selectedGroup?.id ?? "notfound")
            
            AnonymousNotesElement(anonymousNotes: $anonymousNotes)
            
            Text("More settings coming soon")
            
        }
        .padding()
        
    }
    
    
}
