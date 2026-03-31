//
//  CategoryManager.swift
//  RoomateApp
//
//  Created by Ty Dickson on 3/19/26.
//

import FirebaseFirestore
import SwiftUI

@MainActor
class CategoryManager: ObservableObject{
    
    private var db = Firestore.firestore();
    
    //return the category group and the list of categories with it
    func getCategoryGroup() async -> (categoryGroup: CategoryGroup?, categories: [Category]?){
        return (nil,nil)
    }
    
    //get individual category
    func getCategory() async -> Category? {
        return nil
    }
    
    //update the name of the category group
    func updateCategoryGroupName(categoryGroup: CategoryGroup, newName: String){
        
    }
    
    //update the name of the category
    func updateCategoryName(category: Category, newName: String){
        
    }
    
    //create the category group
    func createCategoryGroup(group: GroupItem){
        
    }
    
    //create category
    func createCategory(group: GroupItem){
        
    }
    
    //delete category group and categories with it(func below)
    func deleteCategoryGroup(categoryGroup: CategoryGroup){
        
    }
    
    //delete category from items and delete category
    func deleteCategory(category: Category){
        
    }
    
    //give category id to item and item id to category
    func assignItemCategory(item: Item, category: Category){
        
    }
    
    //remove ids from eachother
    func unassignItemCategory(item: Item, category: Category){
        
    }
    
    
    
}
