//
//  IndividualListView.swift
//  RoomateApp
//
//  Created by Ty Dickson on 3/19/26.
//


import SwiftUI
import FirebaseFirestore


struct IndividualListView: View {
    
    @State private var hideButtons = false

    @State private var searchBarText: String = "";
    @State private var editMode2: Bool = false;
    
    @State private var editMode: EditMode = .inactive
    
    
    @State private var itemName: String = ""
    @State private var isAddVisible: Bool = false;
    @State private var isSearchVisible: Bool = false;
    
    
    @EnvironmentObject var itemManager: ItemManager;
    
    @EnvironmentObject var authManager: AuthManager;
    @EnvironmentObject var groupManager: GroupManager
    
    var filteredItems: [Item] {
        if searchBarText.isEmpty {
            return itemManager.items
        } else {
            return itemManager.items.filter { $0.name.localizedCaseInsensitiveContains(searchBarText) }
        }
    }
    
    func addItem(){
        print(self.itemName)
        itemManager.addItem(name: self.itemName, state: 2, userid: authManager.user!.userID, group: groupManager.myGroup!);
        //firestoreManager.getItems();
        self.itemName = ""
        isAddVisible.toggle()
    }

    
    var body: some View {
        NavigationStack{
            GeometryReader { geo in
                VStack(alignment: .leading, spacing: 20){
                    HStack(){
                        
                        Text(groupManager.myGroup?.name ?? "Group Not Found").font(.title).tint(Color.main)
                        
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
                                itemManager.getItemsLive(group: groupManager.myGroup!)
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
                            
                        }
                        
                    }

                    
                    
                    List{
                        ForEach(filteredItems){ item in
                            
                            ItemRow(item: item, user: authManager.user!)
                            
                            
                            
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
                    .ignoresSafeArea(edges: .bottom)
                    .animation(.easeInOut, value: itemManager.items)
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .onAppear {
                        if let group = groupManager.myGroup {
                            itemManager.getItemsLive(group: group)
                            }
                        
                        //print(authManager.user?.name ?? "none")
                    }
                    .onChange(of: groupManager.myGroup?.id) { _, _ in
                        if let group = groupManager.myGroup {
                            itemManager.getItemsLive(group: group)
                        }
                    }
                    Spacer()
                    
                    
                }
                .padding()
                .edgesIgnoringSafeArea(.bottom)
            }
            .tint(Color.main)
        }
        .tint(Color.main)
    }
        
}
