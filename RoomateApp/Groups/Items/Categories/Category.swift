//
//  Category.swift
//  RoomateApp
//
//  Created by Ty Dickson on 3/19/26.
//

import FirebaseFirestore

struct Category: Identifiable, Codable{
    @DocumentID var id: String?;
    var name: String;
    var categoryGroup: String;
    var color: String;
    var items: [String];
}

