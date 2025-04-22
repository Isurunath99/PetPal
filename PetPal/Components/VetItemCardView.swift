//
//  VetItemCard.swift
//  PetPal
//
//  Created by sasiri rukshan nanayakkara on 4/19/25.
//

import SwiftUI

struct VetItemCardView: View {
    let vet: Vet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // Product Image - Loading from URL instead of asset name
                if let url = URL(string: vet.image) {
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
                    .frame(width: 80, height: 80)
                    .cornerRadius(4)
                    .padding(.leading, 8)
                } else {
                    Image(systemName: "photo")
                        .frame(width: 80, height: 80)
                        .cornerRadius(4)
                        .padding(.leading, 8)
                }
                
                VStack(alignment: .leading) {
                    Text(vet.name)
                        .font(.headline)
                    Text(vet.specialty)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.gray)
                Text(vet.hours)
                    .font(.caption)
                    .bold()
            }
            
            HStack {
                Image(systemName: "phone.fill")
                    .foregroundColor(.gray)
                Text(vet.phone)
                    .font(.subheadline)
            }
            
            HStack(alignment: .top) {
                Image(systemName: "location.fill")
                    .foregroundColor(.gray)
                HStack {
                    Link("Link to Pet Clinic", destination: URL(string: vet.location) ?? URL(string: "https://google.com")!)
                        .foregroundColor(.blue)
                        .underline()
                        .font(.subheadline)
                }
            }

        }
        .padding()
        .frame(width: UIScreen.main.bounds.width * 0.72, alignment: .leading) // 80% width
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}
