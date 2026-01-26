//
//  Item.swift
//  RoomateApp
//
//  Created by Ty Dickson on 1/25/26.
//

import FirebaseFirestore

struct Item: Identifiable, Codable{
    @DocumentID var id: String?;
    var name: String;
    var state: String;
    
}
