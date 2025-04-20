//
//  VetCard.swift
//  PetPal
//
//  Created by sasiri rukshan nanayakkara on 4/19/25.
//

import SwiftUI

struct VetCard: View {
    let item: Vet
    
    var body: some View {
        HStack(spacing: 16) {
            // Product Image - Loading from URL instead of asset name
            if let url = URL(string: item.image) {
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
            
            // Product Information
            VStack(alignment: .leading, spacing: 8) {
                // Two columns: Label and Value
                Group {
                    VetInfoRow(label: "Name", value: item.name)
                    VetInfoRow(label: "Specilaization", value: item.specialty)
                    VetInfoRow(label: "Work Hours", value: item.hours)
                    VetInfoRow(label: "Contact", value: item.phone)
                    HStack {
                        Text("Location")
                            .foregroundColor(.gray)
                            .frame(width: 70, alignment: .leading)
                            .font(.caption) // or .caption, .footnote, etc.
                        
                        Spacer()

                        Link("Link of product", destination: URL(string: item.location) ?? URL(string: "https://google.com")!)
                            .foregroundColor(.blue)
                            .font(.caption) // or .caption, .footnote, etc.
                            .underline()
                    }
                }
            }
            .padding(.vertical, 12)
            
            Spacer()
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
}

struct VetInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
                .font(.caption)
                .frame(minWidth: 70, alignment: .leading)

            Spacer()

            Text(value)
                .foregroundColor(.black)
                .font(.caption)
                .multilineTextAlignment(.trailing)
        }
    }
}
