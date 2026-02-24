//
//  AddGroupView.swift
//  RoomateApp
//
//  Created by Ty Dickson on 2/20/26.
//

import SwiftUI

struct AddGroupView: View{
    
    @State var groupName: String = "";
    @State var code: String = "";
    
    @State var errorText: Bool = false;
    @State var addOrJoin: Bool = false;

    
    @EnvironmentObject var groupManager: GroupManager
    @EnvironmentObject var authManager: AuthManager
    
    
    var body: some View{
        VStack{
            Text("My Groups")
            ForEach(groupManager.groups){ group in
                
                
                Button(action: {
                    print(group.id!)
                    Task{
                        authManager.user = await groupManager.setGroup(group: group, user: authManager.user!)
                        
                        print(authManager.user!.groups)
                    }
                    
                }) {
                    HStack{
                        Text(group.name)
                            .frame(height: 30)
                        Spacer()
                        if(group.id != groupManager.selectedGroup?.id){
                            Text("Select")
                        }
                        
                    }
                    
                    
                    
                }
                .buttonStyle(.borderedProminent)    .tint(group.id == groupManager.selectedGroup?.id ? Color.mainTint : Color.secondary)
                
                

            }
            
            TextField(addOrJoin ? "Create Group (Name)": "Join Group (Name)", text: $groupName)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.main.opacity(0.5), lineWidth: 2)
                )
                .padding(.top, 40)
            TextField("Group Code", text: $code)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.main.opacity(0.5), lineWidth: 2)
                )
            
            if(addOrJoin){
                Button(action:{
                    //isAddVisible = false
                    Task{
                        let user: User  = await groupManager.createGroup(user: authManager.user!,code: code, name: groupName)
                        authManager.user = user
                    }
                    
                }){
                    Text("Create").frame(maxWidth: .infinity)
                        .frame(height: 35)
                }
                .buttonStyle(.borderedProminent).tint(Color.main)
                
            } else{
                Button(action:{
                    Task{
                        let user: User = await groupManager.addMemeber(code: code, user: authManager.user!, name: groupName)
                        
                        if user.userID == authManager.user?.userID{
                            errorText.toggle()
                        }
                        else{
                            
                        }
                        
                    }
                }){
                    Text("Join").frame(maxWidth: .infinity)
                        .frame(height: 35)
                }
                .buttonStyle(.borderedProminent).tint(Color.main)
                if(errorText){
                    Text("Error Joining Group")
                }
            }
            
            Button(action:{
                addOrJoin.toggle()
            }){
                if(!addOrJoin){
                    Text("Create Group")
                }else{
                    Text("Join Group")
                }
            }
            .padding(.top, 20)
            
        }
        .padding()
        
    }
        
}
