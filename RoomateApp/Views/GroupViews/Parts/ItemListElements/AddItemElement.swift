//
//  AddItemElement.swift
//  RoomateApp
//
//  Created by Ty Dickson on 4/7/26.
//

import SwiftUI

struct AddItemElement: View {
    
    let type: Int
    
    @EnvironmentObject var itemManager: ItemManager;
    @EnvironmentObject var authManager: AuthManager;
    @EnvironmentObject var groupManager: GroupManager
    
    @State private var itemName: String = ""
    @State private var isHeader: Bool = false;
    
    func addItem(){
        print(self.itemName)
        itemManager.addItem(name: self.itemName, state: 2, userid: authManager.user!.userID, group: type == 0 ? groupManager.myGroup! : groupManager.selectedGroup!, header: isHeader);
        //firestoreManager.getItems();
        self.itemName = ""
        //isAddVisible.toggle()
    }
    
    
    
    var body: some View {
        VStack(){
            HStack(){
                TextField("Add Item", text:$itemName)
                    .onSubmit {
                        addItem();
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.main.opacity(0.5), lineWidth: 2)
                    )
                Button("Add"){
                    //isAddVisible = false
                    addItem();
                    
                }
                .buttonStyle(.borderedProminent).tint(Color.main)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.main)
                )
                
            }
            HStack(){
                Spacer()
                Button(!isHeader ? "Item" : "Header"){
                    isHeader.toggle()
                }
                Toggle("", isOn: $isHeader)
                    .padding()
                    .labelsHidden()
            }
            Divider()
                .padding(4)
                .tint(Color.secondary)
        }
    }
}
