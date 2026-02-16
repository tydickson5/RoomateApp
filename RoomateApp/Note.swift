//
//  Note.swift
//  RoomateApp
//
//  Created by Ty Dickson on 2/11/26.
//

import FirebaseFirestore

struct Note: Identifiable, Codable{
    @DocumentID var id: String?;
    var note: String;
    var createdAt: Date;
    var user: String;
}
