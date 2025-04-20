//
//  Reminder.swift
//  PetPal
//
//  Created by sasiri rukshan nanayakkara on 4/19/25.
//

import SwiftUI

struct Reminder: Identifiable {
    var id = UUID()
    var date: Date
    var time: Date
    var pet: String
    var task: String
}
