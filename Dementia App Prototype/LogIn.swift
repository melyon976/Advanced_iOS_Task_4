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
    @State private var user: String = "" //placeholder
    @State private var username: String
    @State private var password: String = "Password"
    @State private var showPassword: Bool = false
    
    @FocusState private var usernameIsFocused: Bool
    @FocusState private var passwordIsFocused: Bool
    
    let db = Firestore.firestore()
    @State private var errorMessage: String = ""
    @State private var result: String = "[result]"
    @State private var allUsersResult: String = "No users retrieved yet."
    @State private var soundID = 1543
    @State private var searchFirstName: String = "" // input from user
    
    @State private var pointUsername = 0 //0 mean nothing, 1 means warning, 2 mean success
    @State private var pointPassword = 0
    @State private var usernameMatching = false
    
    @State private var navigate = false
    
    init(usernameParameter: String = "Gracie") {
            self.usernameParameter = usernameParameter
            // Use projected value to set @State
            self._username = State(initialValue: usernameParameter.isEmpty ? "" : usernameParameter)
        }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                VStack(spacing: 18) {
                    // Header
                    VStack(spacing: 6) {
                        Text("Welcome")
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
                        HStack {
                            TextField("Gracie", text: $username)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                        .shadow(radius: 1)
                                )
                                .focused($usernameIsFocused)
                                .onChange(of: usernameIsFocused) { inFocus, offFocus in
                                    if !offFocus && username != "" { //don't know why this works, but it does somehow
                                        print("User clicked out of the text field")
                                        
                                        result = "Attempting to find user..."
                                        allUsersResult = "Fetching users..."
                                        
                                        Task {
                                            do {
                                                // Query Firestore for users where "first_name" matches searchFirstName
                                                let snapshot = try await db.collection("users")
                                                    .whereField("username", isEqualTo: username)
                                                    .getDocuments()
                                                print("---------------------")
                                                print(result)
                                                print(allUsersResult)
                                                
                                                var collectedUserData = ""
                                                if snapshot.documents.isEmpty {
                                                    collectedUserData = "No users found with first name \"\(username)\"."
                                                    pointUsername = 1 //error
                                                    errorMessage = "" //reset error message, let you continue
                                                    usernameMatching = false
                                                } else {
                                                    for document in snapshot.documents {
                                                        let data = document.data()
                                                        let id = document.documentID
                                                        collectedUserData += "ID: \(id)\n"
                                                        collectedUserData += "Name: \(data["first_name"] as? String ?? "N/A") \(data["last_name"] as? String ?? "N/A")\n"
                                                        collectedUserData += "Born: \(data["born"] as? Date ?? Date())\n"
                                                        collectedUserData += "Account type: \(data["account_type"] as? String ?? "N/A")\n"
                                                        collectedUserData += "---\n"
                                                    }
                                                    collectedUserData += "Retrieved on: \(Date())"
                                                    user = username
                                                    pointUsername = 2 //success
                                                    usernameMatching = true
                                                }
                                                
                                                self.allUsersResult = collectedUserData
                                                self.result = "Successfully retrieved users."
                                                print(result)
                                                print(allUsersResult)
                                                print(pointUsername)
                                            } catch {
                                                self.allUsersResult = "Error retrieving documents: \(error.localizedDescription)"
                                                self.result = "Error retrieving documents: \(error.localizedDescription)"
                                            }
                                        }
                                        AudioServicesPlaySystemSound(1255) // feedback sound
                                    }
                                }
                            
                            if username != "" && pointUsername == 1 {
                                Image(systemName: "questionmark")
                                    .foregroundColor(Color(.gray))
                                    .font(.title)
                                    .bold()
                                    .padding(.leading, 10)
                            } else if username != "" && pointUsername == 2 {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color("CustomGreenColor"))
                                    .font(.title)
                                    .bold()
                                    .padding(.leading, 10)
                            }
                            
                        }
                    }
                    
                    // Password
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.caption)
                            .foregroundColor(.black.opacity(0.8))
                            .padding(.horizontal, 12)
                            .padding(.top, 6)
                        
                        HStack {
                            if showPassword {
                                TextField("", text: $password)
                            } else {
                                SecureField("", text: $password)
                            }
                                
                            Spacer()
                            
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
                    
                    Button("Continue"){
                        print("Testing with \(username) + \(password)")
                        Task {
                                if await checkPassword(username: username, inputPassword: password) {
                                    print("Login successful ✅")
                                    pointPassword = 2
                                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                                    UserDefaults.standard.set(username, forKey: "loggedInUsername")
                                    
                                    
                                    navigate = true
                                    // Navigate to PatientListView or do something else
                                } else {
                                    print("Login failed ❌")
                                    // Show an error message
                                    pointPassword = 1
                                }
                        
                        }
                        
                        
                         
                    } .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 50)
                                .fill(Color(.darkAccent))
                        )
                        .foregroundColor(.white)
                        .padding(.top, 6)
                    
                    
                    
                    Spacer().frame(height: 10)
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
                    
                    Spacer()
                    
                }
                .padding(.horizontal)
            }  .navigationDestination(isPresented: $navigate) { // The page it moves to
                if username != "" {
                    PatientListView(usernameParameter: username)
                } else { //should never get here but fail safe
                    PatientListView()
                }
            }
        }
    }
}

func checkPassword(username: String, inputPassword: String) async -> Bool {
    let db = Firestore.firestore()
    print("checking password")
        do {
            // Query for the user document
            let querySnapshot = try await db.collection("users")
                .whereField("username", isEqualTo: username)
                .getDocuments()
            
            // Check if user exists
            guard let userDoc = querySnapshot.documents.first else {
                print("❌ No user found with username: \(username)")
                return false
                
            }
            
            // Get the stored password
            if let storedPassword = userDoc.data()["password"] as? String {
                return storedPassword == inputPassword
            } else {
                print("❌ No password field found for this user")
                return false
            }
        } catch {
            print("❌ Error checking password: \(error.localizedDescription)")
            return false
        }
    
}

#Preview {
    LogIn()
}
