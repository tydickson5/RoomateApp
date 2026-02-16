//
//  NoteRow.swift
//  RoomateApp
//
//  Created by Ty Dickson on 2/14/26.
//

import SwiftUI


struct NoteRow: View{
    
    let note: Note
    let item: Item
    @EnvironmentObject var authManager: AuthManager;
    @ObservedObject var noteManager: NoteManager;
    
    @State var userName: String = "Loading..."
    
    var body: some View{
        VStack(){
            HStack(){
                Text(note.id!)
                Spacer()
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .onTapGesture {
                        deleteNote()
                    }
                
            }
            
            HStack(){
                Spacer()
                Text(userName).font(.footnote)
                    .onAppear{
                        Task{
                            if let user = await authManager.getUser(userid: note.user) {
                                userName = user.name
                            } else {
                                userName = "User"
                            }
                        }
                        
                    }
                
                
            }
            
        }
        Divider()
        
        
    }
    
    private func deleteNote() {
            noteManager.deleteNote(id: note.id!, itemId: item.id!)
        }
}
