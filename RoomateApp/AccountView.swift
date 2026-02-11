//
//  Onboard.swift
//  RoomateApp
//
//  Created by Ty Dickson on 2/3/26.
//

import SwiftUI

struct AccountView: View {
    
    @State private var name: String = "";
    
    @EnvironmentObject var authManager: AuthManager;
    
    var body: some View{
        VStack(){
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
        }
        .padding()
        
    }

}


#Preview {
    AccountView().environmentObject(AuthManager.preview)
}
