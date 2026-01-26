//
//  ContentView.swift
//  RoomateApp
//
//  Created by Ty Dickson on 1/23/26.
//

import SwiftUI
import FirebaseFirestore

struct ContentView: View {
    
    @State private var count = 0;
    let haveItems:  [String] = ["milk", "Eggs", "Bacon"]
    let needItems: [String] = ["paper towel"]
    
    @State private var itemName: String = ""
    
    
    @StateObject private var firestoreManager = FirestoreManager();
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20){
            HStack(){
                Text("Princess Suki's Palace").font(.title).tint(Color.main)
                Spacer();
                Image(systemName: "plus")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .tint(Color.main)
                    
                
                
            }
            HStack(){
                TextField("Add Item", text:$itemName)
                .onSubmit {
                    print(itemName)
                    firestoreManager.addItem(name: itemName, state: "Have")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.main.opacity(0.5), lineWidth: 2)
                )
                Button("X"){
                    
                }
                .buttonStyle(.borderedProminent).tint(Color.main)
                
            }
            List{
                ForEach(firestoreManager.items){ item in
                    //Divider();
                    HStack(){
                        Text(item.name)
                        Spacer()
                        Button(item.state){
                            firestoreManager.updateState(item: item)
                        }
                        .tint(
                            item.state == "Have" ? Color.mainTertiary :
                                item.state == "Low" ? Color.mainTint :
                            Color.main
                        )
                        .buttonStyle(.borderedProminent)
                        
                    }
                }
                .onDelete { indexSet in
                    // Map the index to the actual item in your array
                    indexSet.forEach { index in
                        let item = firestoreManager.items[index]
                        firestoreManager.deleteItem(item: item)
                    }
                }
                
                
                
                
                
            }
            .listStyle(.plain)
            // 4. Hide the overall list background so your ZStack color shows through
            .scrollContentBackground(.hidden)
            .onAppear {
                firestoreManager.getItems();
            }
            Spacer()
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
