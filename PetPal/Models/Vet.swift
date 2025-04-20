//
//  Vet.swift
//  PetPal
//
//  Created by sasiri rukshan nanayakkara on 4/19/25.
//

import SwiftUI

struct Vet: Codable, Identifiable {
    var id = UUID()
    var name: String
    var specialty: String
    var hours: String
    var phone: String
    var location: String
    var image: String
    
}

