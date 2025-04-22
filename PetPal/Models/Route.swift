//
//  Route.swift
//  PetPal
//
//  Created by sasiri rukshan nanayakkara on 3/31/25.
//
import SwiftUI

enum Route: Hashable {
    case profile
    case signIn
    case signUp
    case pet(id: String)
    case addPet
}
