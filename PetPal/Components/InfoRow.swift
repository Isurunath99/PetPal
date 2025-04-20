//
//  InfoRow.swift
//  PetPal
//
//  Created by sasiri rukshan nanayakkara on 4/19/25.
//

import SwiftUI

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
                .frame(width: 70, alignment: .leading)
            
            Text(value)
                .foregroundColor(.black)
        }
    }
}
