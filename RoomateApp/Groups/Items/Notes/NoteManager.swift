//
//  NoteManager.swift
//  RoomateApp
//
//  Created by Ty Dickson on 2/11/26.
//

import FirebaseFirestore
import AuthenticationServices
import SwiftUI

@MainActor
class NoteManager: ObservableObject{
    private var db = Firestore.firestore();
    
    var notesListener: ListenerRegistration?
    @Published var notes: [Note] = []
    
    func stopListening() {
        notesListener?.remove()
        notesListener = nil
    }
    
    func checkNotesExist(itemId: String) {
        db.collection("items").document(itemId).collection("notes").order(by: "createdAt").getDocuments { snapshot, error in
            // This code inside the brackets happens LATER (when the internet responds)
            guard let documents = snapshot?.documents, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            // Update the @Published variable on the main thread
            DispatchQueue.main.async {
                self.notes = documents.compactMap { doc in
                    try? doc.data(as: Note.self)
                }
            }
        }
    }
    
    func getNotesLive(itemId: String) {
        print("getting notes")
        notesListener?.remove()

        notesListener = db.collection("items")
            .document(itemId)
            .collection("notes")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { snapshot, error in
                
                if let error = error {
                    print("Error getting notes:", error)
                    return
                }

                guard let documents = snapshot?.documents else { return }

                let newNotes = documents.compactMap { document in
                    do {
                        return try document.data(as: Note.self)
                    } catch {
                        print("Decoding error:", error)
                        return nil
                    }
                }

                DispatchQueue.main.async {
                    self.notes = newNotes
                    print("Notes updated:", self.notes)
                }
            }
        print(notes)
    }
    
    func deleteNote(id: String, itemId: String) {
        print("deleting")
        print(id)

        // Then delete from Firestore
        db.collection("items").document(itemId).collection("notes").document(id).delete { error in
            if let error = error {
                print("❌ Error deleting note: \(error)")
            } else {
                print("✅ Note deleted successfully")
            }
        }
    }
}
