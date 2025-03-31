//
//  Home.swift
//  PetPal
//
//  Created by sasiri rukshan nanayakkara on 3/31/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var navPath: NavigationPath

    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            ZStack {
                Color(AppColors.primary)
                    .ignoresSafeArea()
                VStack {
                    HStack {
                        Text("Sign In")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 8)
                .padding(.horizontal, 16)
            }
            .frame(height: 50)
            
        }
    }
}
