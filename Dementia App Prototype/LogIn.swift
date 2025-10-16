//
//  LogIn.swift
//  Dementia App Prototype
//
//  Created by Melissa Lyon on 16/10/2025.
//

import SwiftUI

struct LogIn: View {
    @State private var username: String = "" //verify non-matching
    @State private var password: String = ""
    
    @State private var errorMessage: String = ""
    
    var body: some View {
        VStack {
            Text("Log in stuff") .padding()
            Button("Continue") {
                
            }
            .padding()
            .frame(width:200)
            .bold()
            .background(RoundedRectangle(cornerRadius: 50).fill(Color("DarkAccentColor")))
            .foregroundColor(.white)
            
            HStack(spacing: 0) {
                Text("Don't have an account? ")
                Button ("Sign up") {
                    //navlink to SignUp() page
                }
                    .underline()
                    .foregroundColor(.blue)
            }.foregroundColor(.black.opacity(0.7))
                .padding()
        }
    }
}

#Preview {
    LogIn()
}
