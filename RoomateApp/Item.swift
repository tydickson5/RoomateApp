//
//  Item.swift
//  RoomateApp
//
//  Created by Ty Dickson on 1/25/26.
//

import FirebaseFirestore

struct Item: Identifiable, Codable, Equatable{
    @DocumentID var id: String?;
    var name: String;
    var state: Int;
    var user: String;
    var note: String;
    var claimed: String;
    var createdAt: Date;
    var group: String;
    var use: Int; //share, ask, don't use
    var categories: [String]
    var order: Double
}
