//
//  Colors.swift
//  PetPal
//
//  Created by sasiri rukshan nanayakkara on 3/30/25.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let scanner = Scanner(string: hexSanitized)
        
        if hexSanitized.hasPrefix("#") {
            scanner.currentIndex = scanner.string.index(after: scanner.currentIndex)
        }
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let red = Double((rgbValue >> 16) & 0xFF) / 255.0
        let green = Double((rgbValue >> 8) & 0xFF) / 255.0
        let blue = Double(rgbValue & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

struct AppColors {
    static let primary = Color(hex: "#006FFD")
    static let secondary = Color(hex: "#33FF57")
    static let background = Color(hex: "#1E1E1E")
    static let border = Color(hex: "#9CA3AF")
    static let lightBlue = Color(hex: "#7DB4FA")
}
