//
//  SignUp.swift
//  Dementia App Prototype
//
//  Created by Melissa Lyon on 16/10/2025.
//

import SwiftUI
import FirebaseFirestore
import AudioToolbox

enum AccountType: String, CaseIterable, Identifiable {
    case select = "Select"
    case patient = "Patient"
    case carer = "Carer"
    case doctor = "Doctor"
    case other = "Other"
    
    var id: String { self.rawValue }
}

struct SignUp: View {
    @State private var username: String = "Melyon" //verify non-matching
    @State private var password: String = ""
    @State private var full_name: String = "Melissa Lyon" //will be a concadination of given and last name for the database compatability.
    @State private var given_name: String = ""
    @State private var family_name: String = ""
    @State private var born: Date = Date() //check age
    let today = Date()
    @State private var selectedRole: AccountType = .patient
    
    let db = Firestore.firestore()
    @State private var errorMessage: String = ""
    @State private var result: String = "[result]"
    @State private var allUsersResult: String = "No users retrieved yet."
    @State private var soundID = 1543
    @State private var searchFirstName: String = "" // input from user
    @State private var usernameIssue = true
    
    @FocusState private var usernameFieldIsFocused: Bool
    
    var body: some View {
        //ZStack {Color("BackgroundColor")
        //.edgesIgnoringSafeArea(.all)
        //.allowsHitTesting(false) //lets you type into the text fields
        ScrollView{
            VStack (spacing: 15){
                Text("Create an account to get started").font(.title.bold()) .foregroundColor(.black.opacity(0.9)) .multilineTextAlignment(.center)
                
                Spacer().frame(height: 20)
                
                
                if usernameIssue {
                    
                    VStack { // spacing between the text and link
                        Text("The username \"\(username)\" already exists. Please try a different username or")
                            .multilineTextAlignment(.center)
                        
                        
                       
                            NavigationLink("sign in here.") {
                                LogIn(usernameParameter: username)
                            }
                            .underline()
                            .foregroundColor(.blue)
                           
                    }
                    .padding() // shared padding
                    .frame(maxWidth: .infinity) // make both views stretch
                    .foregroundColor(.black.opacity(0.8)) // shared text color
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.customLightGreen)
                            .shadow(radius: 1)
                    )
                }
                
                
                
                /*if errorMessage != "" {
                 Text(errorMessage)
                 .padding()
                 .frame(maxWidth: .infinity)
                 .background(
                 RoundedRectangle(cornerRadius: 10)
                 .fill(Color.customLightGreen)
                 .shadow(radius: 1)
                 )
                 .multilineTextAlignment(.center)
                 .foregroundColor(.black.opacity(0.8))
                 }
                 */
                
                TextField("Full Name", text: $full_name)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white)
                            .shadow(radius: 1)
                    )
                
                HStack {
                    if usernameIssue {
                        Image(systemName: "arrow.turn.down.right")
                            .foregroundColor(Color("CustomGreenColor"))
                            .font(.title)
                            .bold()
                            .padding(.leading, 10)
                    }
                    
                    TextField("Username", text: $username)
                        .padding()
                        .focused($usernameFieldIsFocused)
                        .onChange(of: usernameFieldIsFocused) { inFocus, offFocus in
                            if !offFocus { //don't know why this works, but it does somehow
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
                                            collectedUserData = "No users found with first name \"\(searchFirstName)\"."
                                        } else {
                                            for document in snapshot.documents {
                                                let data = document.data()
                                                let id = document.documentID
                                                collectedUserData += "ID: \(id)\n"
                                                collectedUserData += "Name: \(data["first_name"] as? String ?? "N/A") \(data["last_name"] as? String ?? "N/A")\n"
                                                collectedUserData += "Born: \(data["born"] as? Date ?? Date())\n"
                                                collectedUserData += "Account type: \(data["account_type"] as? String ?? "N/A")\n"
                                                collectedUserData += "---\n"
                                                
                                                errorMessage = "The username \"\(data["username"] as? String ?? "N/A")\" is already taken. Try signing in or use a different username."
                                                
                                                usernameIssue = true
                                            }
                                            collectedUserData += "Retrieved on: \(Date())"
                                        }
                                        
                                        self.allUsersResult = collectedUserData
                                        self.result = "Successfully retrieved users."
                                        print(result)
                                        print(allUsersResult)
                                    } catch {
                                        self.allUsersResult = "Error retrieving documents: \(error.localizedDescription)"
                                        self.result = "Error retrieving documents: \(error.localizedDescription)"
                                    }
                                }
                                AudioServicesPlaySystemSound(1255) // feedback sound
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(radius: 1)
                        )
                    
                }
                
                TextField("Password", text: $password)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                        //                        .stroke(Color.black.opacity(0.5), lineWidth: 1)
                            .shadow(radius: 1)
                    )
                
                HStack {
                    Text("Date of birth: ")
                        .padding()
                    Spacer()
                    DatePicker("Select Date", selection: $born, displayedComponents: [.date])
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .padding(.horizontal, 10)
                }
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                    //                        .stroke(Color.black.opacity(0.5), lineWidth: 1)
                        .shadow(radius: 1)
                )
                
                HStack {
                    
                    Text("Select your role:")
                        .padding()
                    Spacer()
                    
                    Picker("Role", selection: $selectedRole) {
                        ForEach(AccountType.allCases) { role in
                            Text(role.rawValue)
                                .tag(role)
                        }
                    }
                    .pickerStyle(.menu) // dropdown style
                    .background(Color(.systemGray6))
                    .cornerRadius(50)
                    .accentColor(.black)
                    .padding(.horizontal, 10)
                } .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                    //                        .stroke(Color.black.opacity(0.5), lineWidth: 1)
                        .shadow(radius: 1)
                )
                
                Spacer().frame(height: 20)
                
                Button("Sign up") {
                    //add save functionality
                }
                .padding()
                .frame(width:200)
                .bold()
                .background(RoundedRectangle(cornerRadius: 50).fill(.darkAccent))
                .foregroundColor(.white)
                if full_name != "" && !Calendar.current.isDate(born, inSameDayAs: today) && selectedRole != .select {
                    Button("Submit new user") { // adds a new user document
                        print("Attempting to add user...")
                        let nameComponents = full_name.split(separator: " ")
                        let firstName = nameComponents.first.map(String.init) ?? ""
                        let lastName = nameComponents.dropFirst().joined(separator: " ") // in case there is a middle name
                        
                        Task {
                            do {
                                let ref = try await db.collection("users").addDocument(data: [
                                    "first_name": firstName,
                                    "last_name": lastName,
                                    "username": username,
                                    "password": password,
                                    "born": born,
                                    "account_type": selectedRole.rawValue
                                ])
                                
                                print("Document added with ID: \(ref.documentID)")
                            } catch {
                                print("Error adding document: \(error)")
                            }
                        }
                        AudioServicesPlaySystemSound(1104)
                    }
                    .padding()
                    .background(Color("AccentColor"))
                    .foregroundColor(.black)
                    .cornerRadius(20)
                }
                Spacer().frame(height: 10)
                // Sign up link
                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .foregroundColor(.black.opacity(0.7))
                    NavigationLink("Log in") {
                        LogIn()
                    }
                    .underline()
                    .foregroundColor(.blue.opacity(0.9))
                }
                .padding(.bottom, 8)
                
            } .padding(.horizontal, 30)
        }
    }
}

struct SignUp2: View {
    @State private var full_name: String = ""
    var body: some View {
        TextField("Full Name", text: $full_name)
    }
}


#Preview {
    SignUp()
}
