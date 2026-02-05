//
//  Group.swift
//  RoomateApp
//
//  Created by Ty Dickson on 2/3/26.
//

import FirebaseFirestore

struct Group: Identifiable, Codable{
    @DocumentID var id: String?;
    var name: String;
    var users: [User];
}

