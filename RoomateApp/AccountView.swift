//
//  AccountView.swift
//  RoomateApp
//
//  Created by Ty Dickson on 2/3/26.
//

import SwiftUI

struct AccountView: View {
    
    @State private var name: String = "";
    
    @EnvironmentObject var authManager: AuthManager;
    @EnvironmentObject var itemManager: ItemManager;
    
    @State private var suggestion: String = "";
    
    var body: some View{
        NavigationStack{
            VStack(){
                NavigationLink(destination: AddGroupView()){
                    HStack{
                        Image(systemName: "person.2.fill")
                            .imageScale(.large)
                        Text("My Groups")
                        Image(systemName: "arrow.right").imageScale(.large)
                    }
                    
                }
                .padding(.bottom, 30)
                TextField("Name", text: $name)
                    .onSubmit {
                        authManager.changeName(newName: name)
                    }
                    .onAppear(){
                        name = authManager.user?.name ?? "error";
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.main.opacity(0.5), lineWidth: 2)
                    )
                Button(action:{
                    authManager.changeName(newName: name)
                }) {
                    Text("Change Name")
                        .frame(maxWidth: .infinity)
                        .frame(height: 35)
                }
                .buttonStyle(.borderedProminent).tint(Color.main)
                .padding(.bottom, 50)
                
                
                //suggestion form
                HStack{
                    Text("Suggestions here or text Eva").font(.caption).tint(Color.main)
                    Spacer()
                }
                TextEditor(text: $suggestion)

                    .padding(3)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.main.opacity(0.5), lineWidth: 2)
                    )
                    .frame(height: 150)
                Button(action:{
                    authManager.makeSuggestion(suggestion: suggestion)
                    suggestion = ""
                }) {
                    Text("Make Suggestion")
                        .frame(maxWidth: .infinity)
                        .frame(height: 35)
                }
                .buttonStyle(.borderedProminent).tint(Color.mainTint)
                .padding(.bottom, 50)
                
                
                //logout
                Button(action:{
                    
                    Task{
                        
                        try authManager.signOut()
                        itemManager.stopListener()
                    }
                }){
                    Text("Logout")
                        .frame(maxWidth: .infinity)
                        .frame(height: 35)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                
            }
            .padding()
            
        }
        .tint(Color.main)
        
    }

}


#Preview {
    AccountView().environmentObject(AuthManager.preview)
}
