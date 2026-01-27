//
//  ContentView.swift
//  RoomateApp
//
//  Created by Ty Dickson on 1/23/26.
//

import SwiftUI
import FirebaseFirestore

struct ContentView: View {
    
    
    @State private var itemName: String = ""
    @State private var isAddVisible: Bool = false;
    
    
    @StateObject private var firestoreManager = FirestoreManager();
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20){
            HStack(){
                Text("Princess Suki's Palace").font(.title).tint(Color.main)
                Spacer();
                Image(systemName: "line.3.horizontal.decrease")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .tint(Color.main)
                    .onTapGesture {
                        if(firestoreManager.sort){
                            firestoreManager.sort = false
                            firestoreManager.getItems()
                        } else {
                            firestoreManager.sort = true
                            firestoreManager.getItems()
                        }
                    }
                Spacer()
                Image(systemName: "plus")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .tint(Color.main)
                    .onTapGesture {
                        isAddVisible = true
                    }

                
                    
                
                
            }
            HStack(){
                TextField("Add Item", text:$itemName)
                .onSubmit {
                    print(itemName)
                    firestoreManager.addItem(name: itemName, state: "Have")
                    firestoreManager.getItems();
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.main.opacity(0.5), lineWidth: 2)
                )
                Button("X"){
                    isAddVisible = false
                }
                .buttonStyle(.borderedProminent).tint(Color.main)
                
            }
            .opacity(isAddVisible ? 1 : 0)
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
            .scrollContentBackground(.hidden)
            .onAppear {
                firestoreManager.getItems();
            }
            .refreshable {
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
