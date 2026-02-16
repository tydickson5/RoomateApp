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
    let user: User
    
    //@State private var notes: [Note] = [];
    
    @State private var itemName: String = ""
    @State private var showExtraOptions: Bool = false;
    
    @State private var note: String = "";
    
    @StateObject private var firestoreManager = FirestoreManager();
    
    @StateObject private var noteManager = NoteManager();
    
    @EnvironmentObject var authManager: AuthManager;
    //@StateObject var noteManager: NoteManager
    
    @State private var notesExist: Bool = false
    
    
    
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
        firestoreManager.updateNote(item: item, newNote: note, user: user);
        //showExtraOptions = !showExtraOptions
    }
    
    var body: some View {
        //Divider();
        
        VStack(){
            HStack(){
                Text(item.name)
                
                Spacer()
                if(!noteManager.notes.isEmpty){
                    Image(systemName: "note.text")
                        
                        .foregroundStyle(Color.gray)
                        .imageScale(.large)
                        .onTapGesture {
                            showExtraOptions = !showExtraOptions
                        }
                        .frame(width: 20)
                        
                }
                   

                Image(systemName: showExtraOptions ? "chevron.up" : "chevron.down")
                    .foregroundStyle(Color.gray)
                    .imageScale(.large)
                    .onTapGesture {
                        showExtraOptions.toggle()
                        
                        if showExtraOptions {
                            noteManager.getNotesLive(itemId: item.id!)
                        } else {
                            noteManager.stopListening()
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
                    
                    
                    ForEach(noteManager.notes, id: \.id) { note in
                        NoteRow(note: note, item: item, noteManager: noteManager)
                    }
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
                        .frame(height: 50)
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
        .onAppear {
            Task {
                noteManager.checkNotesExist(itemId: item.id!)
            }
        }
        
    }
    
    
}
