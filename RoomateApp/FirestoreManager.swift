//
//  FirestoreManager.swift
//  RoomateApp
//
//  Created by Ty Dickson on 1/25/26.
//
import FirebaseFirestore
import AuthenticationServices
import SwiftUI


class FirestoreManager: ObservableObject{
    private var db = Firestore.firestore();
    
    @Published var items = [Item]()
    
    @Published var sort = true;
    
    @EnvironmentObject var authManager: AuthManager;
    
    
    //get items live
    private var listener: ListenerRegistration?

    func getItemsLive() {
        // Ensure only ONE listener exists
        listener?.remove()

        listener = db.collection("items")
            .order(by: "state", descending: sort)            // primary sort      // secondary sort
        .addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error getting items: \(error)")
                return
            }

            guard let documents = snapshot?.documents else { return }

            let newItems = documents.compactMap {
                try? $0.data(as: Item.self)
            }

            DispatchQueue.main.async {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                    self.items = newItems
                }
            }
        }
    }
    
    func getItems(){
        db.collection("items").order(by: "createdAt", descending: sort).getDocuments { snapshot, error in
            // This code inside the brackets happens LATER (when the internet responds)
            guard let documents = snapshot?.documents, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            // Update the @Published variable on the main thread
            DispatchQueue.main.async {
                self.items = documents.compactMap { doc in
                    try? doc.data(as: Item.self)
                }
            }
        }
        
    }
    
    func getItem(id: String)async -> Item? {

        let docRef = db.collection("items").document(id)
        
        do {
            // Fetch the document once
            let snapshot = try await docRef.getDocument()
            
            // Decode it into your Item struct
            let item = try snapshot.data(as: Item.self)
            return item
        } catch {
            print("Error fetching item: \(error)")
            return nil
        }
    }
    
    //add item
    func addItem(name: String, state: Int, userid: String){
        let newItem = Item(name: name, state: state, user: userid, note: "", claimed: "none", createdAt: Date());
        
        do{
            let _ = try db.collection("items").addDocument(from: newItem);
        }
        catch{
            print("Error adding items\(error)")
        }
        
    }
    
    //update item
    func updateState(item: Item){
        guard let itemId = item.id else { return }

        let newState: Int
        switch item.state {
        case 0: newState = 1
        case 1: newState = 2
        default: newState = 0
        }

        db.collection("items")
            .document(itemId)
            .updateData([
                "state": newState
            ])
    }
    
    func updateNote(item: Item, newNote: String){
        guard let itemId = item.id else { return }

        db.collection("items")
            .document(itemId)
            .updateData([
                "note": newNote
            ])
    }
    
    
    
    
    //delete item
    func deleteItem(item: Item) {
        let db = Firestore.firestore()
        
        db.collection("items").document(item.id!).delete() { error in
            if error == nil {
                DispatchQueue.main.async {
                    self.items.removeAll(where: { $0.id == item.id })
                }
            }
        }
    }
}
