//
//  List.swift
//  RoomateApp
//
//  Created by Ty Dickson on 4/7/26.
//

import SwiftUI

struct ItemList: View {
    
    let type: Int;
    
    @EnvironmentObject var itemManager: ItemManager;
    @EnvironmentObject var authManager: AuthManager;
    @EnvironmentObject var groupManager: GroupManager
    
    @State private var hideButtons = false

    @State private var searchBarText: String = "";
    
    
    @State private var isAddVisible: Bool = false;
    @State private var isSearchVisible: Bool = false;
    @State private var editMode2: Bool = false;
    
    @State private var editMode: EditMode = .inactive
    
    
    
    
    
    var filteredItems: [Item] {
        if searchBarText.isEmpty {
            return itemManager.items
        } else {
            return itemManager.items.filter { $0.name.localizedCaseInsensitiveContains(searchBarText) }
        }
    }
    
    
    
    var body: some View {
        NavigationStack{
            GeometryReader { geo in
                VStack(alignment: .leading, spacing: 20){
                    HStack(){
                        
                        Text(type == 0 ? groupManager.myGroup?.name ?? "Group Not Found" : groupManager.selectedGroup?.name ?? "Group Not Found").font(.title).tint(Color.main)
                        
                        Spacer()
                        NavigationLink( destination: GroupSettingsView()){
                            Image(systemName: "gearshape.fill").imageScale(.large)
                        }
                        
                        
                    }
                    HStack(){
                        HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                TextField("Search items", text: $searchBarText)
                                    .textFieldStyle(.plain)
                                
                                if !searchBarText.isEmpty {
                                    Button(action: { searchBarText = "" }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        Spacer();
                        if(!itemManager.sort){
                            Image(systemName: editMode2 ? "xmark": "pencil")
                                .imageScale(.large)
                                .foregroundStyle(.tint)
                                .tint(Color.main)
                                .padding(.leading, 5)
                                .onTapGesture {
                                    editMode2 = !editMode2
                                }
                        }
                        

                        Image(systemName: "line.3.horizontal.decrease")
                            .imageScale(.large)
                            .foregroundStyle(.tint)
                            .tint(Color.main)
                            .padding(.leading, 5)
                            .onTapGesture {
                                itemManager.sort = !itemManager.sort
                                itemManager.getItemsLive(group: (type == 0 ? groupManager.myGroup! : groupManager.selectedGroup)!)
                            }
                        
                        Image(systemName: isAddVisible ? "xmark": "plus")
                            .imageScale(.large)
                            .foregroundStyle(.tint)
                            .tint(Color.main)
                            .onTapGesture {
                                isAddVisible = !isAddVisible
                                
                            }.padding(3)
                    }

                    
                    
                    
                    if(isAddVisible){
                        
                        
                        AddItemElement(type: type)
                        
                    }

                    
                    
                    ListElement(type: type, filteredItems: filteredItems, searchBarText: searchBarText, editMode2: editMode2)
                    Spacer()
                    
                    
                }
                .padding()
            }
            .tint(Color.main)
        }
        .tint(Color.main)
    }
    
}
