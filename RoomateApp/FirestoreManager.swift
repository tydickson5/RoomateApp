//
//  FirestoreManager.swift
//  RoomateApp
//
//  Created by Ty Dickson on 1/25/26.
//
import FirebaseFirestore


class FirestoreManager: ObservableObject{
    private var db = Firestore.firestore();
    
    @Published var items = [Item]()
    
    @Published var sort = true;
    
    
    //get items live
    func getItemsLive(){
        
        db.collection("items").order(by: "state", descending: sort).addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error getting items: \(error)")
                return
            }
            
            self.items = snapshot?.documents.compactMap { document in
                try? document.data(as: Item.self)
            } ?? []
        }
        
    }
    
    func getItems(){
        db.collection("items").order(by: "state", descending: sort).getDocuments { snapshot, error in
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
    func addItem(name: String, state: String){
        let newItem = Item(name: name, state: state);
        
        do{
            let _ = try db.collection("items").addDocument(from: newItem);
        }
        catch{
            print("Error adding items\(error)")
        }
        
    }
    
    //update item
    func updateState(item: Item){
        guard let itemId = item.id else {return};
        
        var newState: String;
        
        if(item.state == "Have"){
            newState = "Low"
        } else if(item.state == "Low"){
            newState = "Need"
        } else {
            newState = "Have"
        }
        
        let newItem = Item(id: itemId, name: item.name, state: newState);
        
        do {
            try db.collection("items").document(itemId).setData(from: newItem)
            if let index = items.firstIndex(where: { $0.id == itemId }) {
                items[index].state = newState
            }

        } catch {
            print("Error updating note: \(error)")

        }
    }
    
    
    
    
    //delete item
    func deleteItem(item: Item){
        guard let itemId = item.id else { return }
                
        db.collection("items").document(itemId).delete { error in
            if let error = error {
                print("Error deleting note: \(error)")
            }
        }
    }
}
