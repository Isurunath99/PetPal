//
//  PetItemCardView.swift
//  PetPal
//
//  Created by sasiri rukshan nanayakkara on 4/19/25.
//

import SwiftUI

struct PetItemCardView: View {
    let pet: Pet
    
    var body: some View {
        VStack {
            // Product Image - Loading from URL instead of asset name
            if let url = URL(string: pet.image) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 80, height: 80)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    @unknown default:
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    }
                }
                .scaledToFill()
                .frame(width: 70, height: 70)
                .background(pet.name == "Shadow" ? Color.yellow : Color.orange)
                .cornerRadius(12)
            } else {
                Image(systemName: "photo")
                    .frame(width: 80, height: 80)
                    .cornerRadius(4)
                    .padding(.leading, 8)
            }
            
            Text(pet.name)
                .font(.subheadline)
                .padding(.top, 4)
        }
        .frame(width: 80)
    }
}
