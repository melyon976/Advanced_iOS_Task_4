//
//  LogIn.swift
//  Dementia App Prototype
//
//  Created by Melissa Lyon on 16/10/2025.
//

import SwiftUI
import FirebaseFirestore
import AudioToolbox

struct LogIn: View {
    var usernameParameter: String = "you@example.com"  // value passed in
    @State private var username: String
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    
    init(usernameParameter: String = "you@example.com") {
            self.usernameParameter = usernameParameter
            self._username = State(initialValue: usernameParameter)
        }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                VStack(spacing: 18) {
                    // Header
                    VStack(spacing: 6) {
                        Text("Welcome back")
                            .font(.title.bold())
                            .foregroundColor(.black.opacity(0.9))
                        Text("Log in to continue")
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.6))
                    }
                    .padding(.top, 12)
                    
                    // Email
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Username")
                            .font(.caption)
                            .foregroundColor(.black.opacity(0.8))
                            .padding(.horizontal, 12)
                            .padding(.top, 6)
                        
                        TextField("", text: $username)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                                    .shadow(radius: 1)
                            )
                    }
                    
                    // Password
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.caption)
                            .foregroundColor(.black.opacity(0.8))
                            .padding(.horizontal, 12)
                            .padding(.top, 6)
                        
                        HStack {
                            Group {
                                if showPassword {
                                    TextField("••••••••", text: $password)
                                } else {
                                    SecureField("••••••••", text: $password)
                                }
                            }
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            
                            Button {
                                showPassword.toggle()
                            } label: {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.black.opacity(0.6))
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(radius: 1)
                        )
                    }
                    
                    // Forgot password
                    HStack {
                        Spacer()
                        Button("Forgot password?") {
                        }
                        .font(.footnote.bold())
                        .foregroundColor(.black.opacity(0.7))
                    }
                    .padding(.top, 2)
                    
                    Button {
                    } label: {
                        Text("Continue")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 50)
                            .fill(Color(.darkAccent))
                    )
                    .foregroundColor(.white)
                    .padding(.top, 6)
                    
                    Spacer().frame(height: 20)
                    // Sign up link
                    HStack(spacing: 4) {
                        Text("Don't have an account yet?")
                            .foregroundColor(.black.opacity(0.7))
                        NavigationLink("Sign up") {
                            SignUp()
                        }
                        .underline()
                        .foregroundColor(.blue.opacity(0.9))
                    }
                    .padding(.bottom, 8)
                    
                    
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    LogIn()
}
