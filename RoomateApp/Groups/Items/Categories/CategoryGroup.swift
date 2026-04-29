//
//  CategoryGroup.swift
//  RoomateApp
//
//  Created by Ty Dickson on 3/19/26.
//
import FirebaseFirestore

struct CategoryGroup: Identifiable, Codable{
    @DocumentID var id: String?;
    var name: String;
    var group: String;
    
}
