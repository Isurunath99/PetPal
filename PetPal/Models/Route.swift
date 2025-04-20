//
//  Route.swift
//  PetPal
//
//  Created by sasiri rukshan nanayakkara on 3/31/25.
//

import SwiftUI

enum Route: Hashable {
    case home
    case profile
    case signIn
    case signUp
    case vet
    case shop
    case discover
    case reminder
    case pet(id: String)
    case addPet
}
