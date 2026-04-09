//
//  ListElement.swift
//  RoomateApp
//
//  Created by Ty Dickson on 4/7/26.
//

import SwiftUI

struct ListElement: View {
    
    let type: Int
    let filteredItems: [Item]
    let searchBarText: String
    let editMode2: Bool
    
    @EnvironmentObject var itemManager: ItemManager;
    @EnvironmentObject var authManager: AuthManager;
    @EnvironmentObject var groupManager: GroupManager
    
    var body: some View {
        List{
            
            ForEach(filteredItems){ item in
                
                if let header = item.header {
                    if(header && !itemManager.sort){
                        HeaderRow(text: item.name)
                    }
                    else if(!header){
                        ItemRow(item: item, user: authManager.user!)
                    }
                } else {
                    ItemRow(item: item, user: authManager.user!)
                }
                
            }
            .onMove { source, destination in
                itemManager.moveItem(from: source, to: destination)
            }
            .onDelete { indexSet in
                // Map the index to the actual item in your array
                indexSet.forEach { index in
                    let item = filteredItems[index]
                    itemManager.deleteItem(item: item)
                }
            }
            
        }
        .environment(\.editMode, searchBarText.isEmpty && itemManager.sort == false && editMode2 == true ? .constant(.active) : .constant(.inactive))
        .animation(.easeInOut, value: itemManager.items)
        .listStyle(.plain)
        .contentMargins(.bottom, 45, for: .scrollContent)
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            if let group = (type == 0 ? groupManager.myGroup : groupManager.selectedGroup) {
                itemManager.getItemsLive(group: group)
            }
            
        
            //print(authManager.user?.name ?? "none")
        }
        .onChange(of: type == 0 ? groupManager.myGroup?.id : groupManager.selectedGroup?.id) { _, _ in
            if let group = (type == 0 ? groupManager.myGroup! : groupManager.selectedGroup) {
                itemManager.getItemsLive(group: group)
            }
        }
    }
}
