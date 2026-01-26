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
                Text("Princess Suki's Palace").font(.title)
                Spacer();
                Image(systemName: "plus")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    
                
                
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
                        .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                )
                
            }
            VStack{
                ForEach(firestoreManager.items){ item in
                    Divider();
                    HStack(){
                        Text(item.name)
                        Spacer()
                        Button(item.state){
                            firestoreManager.updateState(item: item)
                        }
                        .buttonStyle(.borderedProminent)
                        
                    }
                }
                
                
                
                
                
                
            }
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
