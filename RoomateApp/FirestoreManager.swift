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
    
    
    //get items
    func getItems(){
        
        db.collection("items").order(by: "state").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error getting notes: \(error)")
                return
            }
            
            self.items = snapshot?.documents.compactMap { document in
                try? document.data(as: Item.self)
            } ?? []
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
        guard var itemId = item.id else {return};
        
        var newState: String;
        
        if(item.state == "Have"){
            newState = "Low"
        } else if(item.state == "Low"){
            newState = "Need"
        } else {
            newState = "Have"
        }
        
        var newItem = Item(id: itemId, name: item.name, state: newState);
        
        do {
            try db.collection("items").document(itemId).setData(from: newItem)
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
