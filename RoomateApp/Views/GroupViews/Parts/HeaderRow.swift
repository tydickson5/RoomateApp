//
//  HeaderItem.swift
//  RoomateApp
//
//  Created by Ty Dickson on 4/7/26.
//

import SwiftUI

struct HeaderRow: View {
    
    let text: String
    
    var body: some View {
        Text(text).bold().font(.title)
    }
    
}
