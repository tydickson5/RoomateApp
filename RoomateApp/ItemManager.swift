//
//  FirestoreManager.swift
//  RoomateApp
//
//  Created by Ty Dickson on 1/25/26.
//
import FirebaseFirestore
import AuthenticationServices
import SwiftUI


class ItemManager: ObservableObject{
    private var db = Firestore.firestore();
    
    @Published var items = [Item]()
    
    @Published var sort = false;
    
    //@EnvironmentObject var authManager: AuthManager;
    
    //get items live
    private var listener: ListenerRegistration?

    func getItemsLive(group: GroupItem) {
        // Ensure only ONE listener exists
        /* WHEN YOU NEED TO ADD SOMETHING TO AN ITEM
         db.collection("items").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }

            for doc in docs {
                doc.reference.updateData([
                    "categories": []
                ])
            }
        }
         */
        

        stopListener()
        items.removeAll()
        
        let query: Query

        if sort {
            query = db.collection("items")
                .whereField("group", isEqualTo: group.id!)
                .order(by: "state")
                .order(by: "order")  // Secondary sort by lexicographic order
        } else {
            query = db.collection("items")
                .whereField("group", isEqualTo: group.id!)
                .order(by: "order")  // Order by lexicographic order
        }
        
        listener = query.addSnapshotListener { [weak self] snapshot, error in
            Task { @MainActor in
                guard let documents = snapshot?.documents else { return }
                self?.items = documents.compactMap { try? $0.data(as: Item.self) }
            }
        }
    }
    func stopListener() {
        listener?.remove()
        listener = nil
        items.removeAll()
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
    func addItem(name: String, state: Int, userid: String, group: GroupItem){
        
        
        
        let maxOrder = items.map { $0.order }.max() ?? 0.0
        let nextOrder = maxOrder + 1000.0

        let newItem = Item(name: name, state: state, user: userid, note: "", claimed: "none", createdAt: Date(), group: group.id!, use: 0, categories: [], order: nextOrder);
        
        do{
            let _ = try db.collection("items").addDocument(from: newItem);
        }
        catch{
            print("Error adding items\(error)")
        }
        
    }
    
    func moveItem(from source: IndexSet, to destination: Int) {
        guard let sourceIndex = source.first else { return }
        guard !sort else { return }
        
        // Get the item ID before moving
        let movingItem = items[sourceIndex]
        guard let itemId = movingItem.id else { return }
        
        print("📍 Moving '\(movingItem.name)' from \(sourceIndex) to \(destination)")
        
        // Move in local array
        items.move(fromOffsets: source, toOffset: destination)
        
        // Find where the item ended up after the move
        guard let newIndex = items.firstIndex(where: { $0.id == itemId }) else {
            print("❌ Couldn't find moved item")
            return
        }
        
        print("📍 Item now at index \(newIndex)")
        
        // Calculate new order based on neighbors
        let newOrder: Double
        
        if items.count == 1 {
            newOrder = 1000.0
        } else if newIndex == 0 {
            let nextOrder = items[1].order
            newOrder = nextOrder / 2.0
        } else if newIndex >= items.count - 1 {
            let prevOrder = items[newIndex - 1].order
            newOrder = prevOrder + 1000.0
        } else {
            let prevOrder = items[newIndex - 1].order
            let nextOrder = items[newIndex + 1].order
            let gap = nextOrder - prevOrder
            
            if gap < 0.000001 {
                rebalanceSection(around: newIndex)
                return
            }
            
            newOrder = prevOrder + (gap / 2.0)
        }
        
        print("🔄 New order: \(newOrder)")
        
        // Update in Firestore
        Task {
            try? await db.collection("items").document(itemId).updateData(["order": newOrder])
        }
    }
    // Only rebalance a small section when needed
    private func rebalanceSection(around index: Int) {
        let start = max(0, index - 2)
        let end = min(items.count - 1, index + 2)
        
        print("⚖️ Rebalancing section [\(start)...\(end)]")
        
        Task {
            for i in start...end {
                let item = items[i]
                guard let itemId = item.id else { continue }
                
                let newOrder = Double(i) * 1000.0
                
                try? await db.collection("items").document(itemId).updateData([
                    "order": newOrder
                ])
            }
            print("✅ Section rebalanced")
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
    
    func updateNote(item: Item, newNote: String, user: User){
        guard let itemId = item.id else { return }

        db.collection("items").document(itemId).collection("notes").addDocument(data: [
            "note": newNote,
            "createdAt": FieldValue.serverTimestamp(),
            "user": user.userID
        ])
    }
    
    
    func migrateToDoubleOrder() async {
        print("🔄 Adding order field to all items...")
            
        do {
            let snapshot = try await db.collection("items")
                .order(by: "createdAt")
                .getDocuments()
            
            for (index, doc) in snapshot.documents.enumerated() {
                try await doc.reference.updateData(["order": Double(index) * 1000.0])
            }
            
            print("✅ Migration complete! Updated \(snapshot.documents.count) items")
        } catch {
            print("❌ Migration error: \(error)")
        }
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
    
    
    func migrateToLexicographicOrder() async {
        print("🔄 Migrating items to lexicographic ordering...")
        
        do {
            let snapshot = try await db.collection("items")
                .order(by: "createdAt")
                .getDocuments()
            
            var currentOrder = "n"
            
            for doc in snapshot.documents {
                try await doc.reference.updateData(["order": currentOrder])
                currentOrder = generateOrderBetween(prev: currentOrder, next: nil)
            }
            
            print("✅ Migration complete!")
        } catch {
            print("❌ Migration error: \(error)")
        }
    }
    
    
    
}
extension ItemManager {
    
    // Generate a string that's lexicographically between two strings
    func generateOrderBetween(prev: String?, next: String?) -> String {
        let base = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        let midChar = "n"
        
        // First item ever
        if prev == nil && next == nil {
            return midChar
        }
        
        // Insert at beginning
        if prev == nil {
            guard let next = next else { return midChar }
            
            // If next is empty or very short, prepend a character
            if next.isEmpty {
                return "0"
            }
            
            let firstChar = next.first!
            
            if firstChar == base.first! {
                // Next starts with lowest char, prepend to it
                return "0" + next
            } else {
                // Return char before next's first char
                if let index = base.firstIndex(of: firstChar) {
                    let prevIndex = base.index(before: index)
                    return String(base[prevIndex])
                }
                return "0"
            }
        }
        
        // Insert at end
        if next == nil {
            guard let prev = prev else { return midChar }
            return prev + midChar
        }
        
        // Insert in middle
        guard let prev = prev, let next = next else {
            return midChar
        }
        
        // Check if we can insert a character between them
        let minLength = min(prev.count, next.count)
        
        for i in 0..<minLength {
            let prevChar = prev[prev.index(prev.startIndex, offsetBy: i)]
            let nextChar = next[next.index(next.startIndex, offsetBy: i)]
            
            if prevChar != nextChar {
                // Found difference at position i
                if let prevIndex = base.firstIndex(of: prevChar),
                   let nextIndex = base.firstIndex(of: nextChar) {
                    
                    let distance = base.distance(from: prevIndex, to: nextIndex)
                    
                    if distance > 1 {
                        // Can fit a character between them
                        let midIndex = base.index(prevIndex, offsetBy: distance / 2)
                        let prefix = prev.prefix(i)
                        return String(prefix) + String(base[midIndex])
                    } else {
                        // Adjacent characters, need to append
                        let prefix = prev.prefix(i + 1)
                        return String(prefix) + midChar
                    }
                }
            }
        }
        
        // Strings are identical up to minLength
        // Append to the shorter one (or prev if equal length)
        if prev.count < next.count {
            return prev + midChar
        } else {
            return prev + midChar
        }
    }
}
