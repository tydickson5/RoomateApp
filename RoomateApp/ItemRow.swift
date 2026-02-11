//
//  ItemRow.swift
//  RoomateApp
//
//  Created by Ty Dickson on 2/8/26.
//

import SwiftUI
import FirebaseFirestore

struct ItemRow: View {
    
    let item: Item
    
    @State private var itemName: String = ""
    @State private var showExtraOptions: Bool = false;
    
    @State private var note: String = "";
    
    @StateObject private var firestoreManager = FirestoreManager();
    
    
    
    func getItemState(state: Int) -> String{
        if(state == 2){
            return "Need"
        } else if(state == 1){
            return "Low"
        }else{
            return "Have"
        }
    }
    
    func getItemStateTint(state: Int) -> Color{
        if(state == 2){
            return Color.mainTertiary
        } else if(state == 1){
            return Color.mainTint
        }else{
            return Color.main
        }
    }
    
    func updateItemNote(){
        firestoreManager.updateNote(item: item, newNote: note);
        showExtraOptions = !showExtraOptions
    }
    
    var body: some View {
        //Divider();
        
        VStack(){
            HStack(){
                Text(item.name)
                
                Spacer()
                if(item.note != ""){
                    Image(systemName: "note.text")
                        .foregroundStyle(Color.gray)
                        .imageScale(.large)
                        .onTapGesture {
                            showExtraOptions = !showExtraOptions
                        }
                        .frame(width: 20)
                }

                if(showExtraOptions){
                    Image(systemName: "chevron.up")
                        .foregroundStyle(Color.gray)
                        .imageScale(.large)
                        .onTapGesture {
                            showExtraOptions = !showExtraOptions
                        }
                } else{
                    Image(systemName: "chevron.down")
                        .foregroundStyle(Color.gray)
                        .imageScale(.large)
                        .onTapGesture {
                            showExtraOptions = !showExtraOptions
                        }
                }
                
                Button(action: {
                    firestoreManager.updateState(item: item)
                }) {
                    Text(getItemState(state: item.state))
                        .frame(width: 50)
                }
                .tint(getItemStateTint(state: item.state))
                .buttonStyle(.borderedProminent)
                
            }
            if(showExtraOptions){
                VStack(){
                    TextEditor(text: $note)
                        .onSubmit {
                            updateItemNote()
                        }
                        .onAppear {
                            note = item.note
                        }
                        .padding(3)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.main.opacity(0.5), lineWidth: 2)
                        )
                        .frame(height: 100)
                    HStack(){

                        Spacer()
                        Button("Update"){
                            updateItemNote()
                        }
                        .buttonStyle(.borderedProminent).tint(Color.main)
                    }
                    
                }
            }
            
            
        }
        .animation(.spring(), value: item.state)
        
    }
    
    
}
