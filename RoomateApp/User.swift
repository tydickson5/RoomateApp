//
//  User.swift
//  RoomateApp
//
//  Created by Ty Dickson on 2/3/26.
//

import FirebaseFirestore

struct User: Identifiable, Codable{
    @DocumentID var id: String?;
    var userID: String;
    var name: String;
    var groups: [GroupItem];
}
