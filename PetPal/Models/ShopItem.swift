//
//  ShopItem.swift
//  PetPal
//
//  Created by sasiri rukshan nanayakkara on 4/19/25.
//

import SwiftUI

struct ShopItem: Identifiable {
    var id = UUID()
    var name: String
    var quantity: String
    var price: Double
    var link: String
    var image: String
}
