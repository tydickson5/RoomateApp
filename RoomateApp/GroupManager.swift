//
//  GroupManager.swift
//  RoomateApp
//
//  Created by Ty Dickson on 2/17/26.
//

import FirebaseFirestore
import SwiftUI

@MainActor
class GroupManager: ObservableObject{
    private var db = Firestore.firestore();
    
    @Published var groups: [GroupItem] = [];
    @Published var selectedGroup: GroupItem? = nil;
    
    @EnvironmentObject var authManager: AuthManager
        

    func getGroup(groupid: String) async -> GroupItem? {
        let docRef = db.collection("groups").document(groupid)
        
        do{
            let snapshot = try await docRef.getDocument()
            
            let group = try snapshot.data(as: GroupItem.self)
            return group
        } catch {
            print("error getting group")
            return nil;
        }
    }
    
    func getUserGroups(user: User) async{
        guard !user.groups.isEmpty else {
            self.groups = []
            return
        }

        do {
            let snapshot = try await db.collection("groups")
                .whereField(FieldPath.documentID(), in: user.groups)
                .getDocuments()

            let fetchedGroups = snapshot.documents.compactMap {
                try? $0.data(as: GroupItem.self)
            }

            // 🔥 Preserve order from user.groups
            let orderedGroups = user.groups.compactMap { id in
                fetchedGroups.first(where: { $0.id == id })
            }

            self.groups = orderedGroups
            self.selectedGroup = orderedGroups.first

        } catch {
            print("Error fetching groups:", error)
        }
        
    }
    
    func setGroup(group: GroupItem, user: User) async -> User?{
        
        guard var groupId = group.id,
              var userId = user.id else { return user }

        selectedGroup = group

        var updatedGroupIds = user.groups ?? []

        updatedGroupIds.removeAll { $0 == groupId }
        updatedGroupIds.insert(groupId, at: 0)

        //print("NEW ORDER:", updatedGroupIds)

        do {
            try await db.collection("users")
                .document(userId)
                .updateData([
                    "groups": updatedGroupIds
                ])

            var updatedUser = user
            updatedUser.groups = updatedGroupIds

            await getUserGroups(user: updatedUser)
            
            return updatedUser
        } catch {
            print(error)
            return user
        }
    

    }
    
    func addMemeber(code: String, user: User, name: String) async -> User{
        
        do{
            
            //check user is not already in it
        
            let snapshot = try await db.collection("groups")
                    .whereField("name", isEqualTo: name)
                    .getDocuments()

            guard let document = snapshot.documents.first else {
                print("Group not found")
                return user
            }

            let groupId = document.documentID
            let group = try document.data(as: GroupItem.self)

            // 2️⃣ Check code
            guard group.code == code else {
                print("Invalid code")
                return user
            }
            
            if group.users.contains(user.id!) {
                print("User already in group")
                return user
            }

            // 3️⃣ Add group to user
            try await db.collection("users")
                .document(user.id!)
                .updateData([
                    "groups": FieldValue.arrayUnion([groupId])
                ])

            // 4️⃣ Add user to group
            try await db.collection("groups")
                .document(groupId)
                .updateData([
                    "users": FieldValue.arrayUnion([user.id!])
                ])
            
            var newUser = await setGroup(group: group, user: user) ?? user

            return newUser

        } catch {
            print("Error joining group:", error)
            return user
        }

    }
    
    func createGroup(user: User, code: String, name: String) async -> User{
        
        do{
            let docRef = try await db.collection("groups").addDocument(data: [
                    "name": name,
                    "users": [user.id!],
                    "code": code,
                    "createdAt": Date(),
                    "owner": user.id!
                ])
            
            //await getUserGroups(user: user)
            //setGroup(group: groups[groups.count-1])
            
            let updatedGroups = Array(Set(user.groups + [docRef.documentID]))  // Use document ID, not the group object!
                        
            try await db.collection("users").document(user.id!).updateData([
                "groups": updatedGroups
            ])
            
            print("User document updated with new group")
            
            // Reload groups
            //authManager.user?.groups = updatedGroups
            let snapshot = try await db.collection("groups").whereField("name", isEqualTo: name).whereField( "code", isEqualTo: code)
                .getDocuments()
            guard let document = snapshot.documents.first else {
                print("error")
                return user
            }
            let group = try document.data(as: GroupItem.self)
            await getUserGroups(user: user)

            // Set the newly created group as selected
            if let newGroup = groups.first(where: { $0.id == docRef.documentID }) {
                await setGroup(group: newGroup, user: user)
            }
            
            
            
            var newUser = await setGroup(group: group, user: user) ?? user
            
            return newUser
        } catch {
            
            print(error)
            return user
        }
        
        
    }
    
    func updateGroupName(newName: String){
        db.collection("groups").document(selectedGroup!.id!).updateData(["name": newName])
    }
}
