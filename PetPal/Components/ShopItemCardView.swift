//
//  ShopItemCardView.swift
//  PetPal
//
//  Created by sasiri rukshan nanayakkara on 4/19/25.
//

import SwiftUI

struct ShopItemCardView: View {
    let item: ShopItem
    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter
    }()
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Image section (fixed width: 80)
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
//            Image(systemName: item.image)
//                .resizable()
//                .scaledToFit()
//                .frame(width: 80, height: 80)
//                .padding(8)
//                .background(Color.yellow.opacity(0.3))
//                .cornerRadius(8)
//            
            // Text content
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(2)
                
                HStack {
                    Image(systemName: "tag.fill")
                        .foregroundColor(.gray)
                    Text(numberFormatter.string(from: NSNumber(value: item.price)) ?? "")
                        .font(.subheadline)
                        .bold()
                }
                
                HStack(alignment: .top) {
                    Image(systemName: "location.fill")
                        .foregroundColor(.gray)
//                    Text(item.name)
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                        .fixedSize(horizontal: false, vertical: true)
                    HStack {                        
                        Link("Link of product", destination: URL(string: item.link) ?? URL(string: "https://google.com")!)
                            .foregroundColor(.blue)
                            .underline()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width * 0.9, alignment: .leading)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}
