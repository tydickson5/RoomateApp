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

struct HomeView: View {
    
    
    @State private var itemName: String = ""
    @State private var isAddVisible: Bool = false;
    
    
    @StateObject private var firestoreManager = FirestoreManager();
    
    @EnvironmentObject var authManager: AuthManager;
    
    func addItem(){
        print(self.itemName)
        firestoreManager.addItem(name: self.itemName, state: 2, userid: authManager.user!.userID);
        //firestoreManager.getItems();
        self.itemName = ""
    }

    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20){
            HStack(){
                Text("Princess Suki's Palace").font(.title).tint(Color.main)
                //Text(authManager.user?.name ?? "noneuser")
                //Button("signout"){
                //    Task{
                //        try authManager.signOut()
                //    }
                    
                //}
                Spacer();
            
                Image(systemName: "line.3.horizontal.decrease")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .tint(Color.main)
                    .onTapGesture {
                        firestoreManager.sort = !firestoreManager.sort
                        firestoreManager.getItemsLive()
                    }

                Image(systemName: isAddVisible ? "xmark": "plus")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .tint(Color.main)
                    .onTapGesture {
                        isAddVisible = !isAddVisible
                        
                    }

                
                    
                
                
            }
            
            if(isAddVisible){
                HStack(){
                    TextField("Add Item", text:$itemName)
                    .onSubmit {
                        addItem();
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.main.opacity(0.5), lineWidth: 2)
                    )
                    Button("Add"){
                        //isAddVisible = false
                        addItem();
                        
                    }
                    .buttonStyle(.borderedProminent).tint(Color.main)
                    
                }
                
            }
            
            
            List{
                ForEach(firestoreManager.items){ item in
                    
                    ItemRow(item: item)
                    
                    
                    
                }
                .onDelete { indexSet in
                    // Map the index to the actual item in your array
                    indexSet.forEach { index in
                        let item = firestoreManager.items[index]
                        firestoreManager.deleteItem(item: item)
                    }
                }
                
                
                
                
                
                
            }
            .animation(.easeInOut, value: firestoreManager.items)
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .onAppear {
                firestoreManager.getItemsLive();
                //print(authManager.user?.name ?? "none")
            }
            Spacer()
            
        }
        .padding()
    }
}



#Preview {
    HomeView()
        .environmentObject(AuthManager.preview)
}
