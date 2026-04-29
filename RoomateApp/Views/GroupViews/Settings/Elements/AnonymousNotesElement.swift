//
//  AnonymousNotesElement.swift
//  RoomateApp
//
//  Created by Ty Dickson on 4/8/26.
//

import SwiftUI

struct AnonymousNotesElement: View {
    
    @Binding var anonymousNotes: Bool;
    
    var body: some View {
        HStack {
            Text("Make notes anonymous").foregroundColor(Color.main)
            Spacer()
            Toggle("", isOn: $anonymousNotes)
                .labelsHidden()
        }
        .padding()
        .frame(height: 45)
        .background(Color.google)
        .foregroundColor(.white)
        .cornerRadius(8)
    }
}
