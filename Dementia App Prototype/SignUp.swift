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
    @State private var user: String = "" //placeholder
    @State private var username: String = "" //verify non-matching
    @State private var password: String = ""
    @State private var full_name: String = "" //will be a concadination of given and last name for the database compatability.
    @State private var given_name: String = ""
    @State private var family_name: String = ""
    @State private var born: Date = Date() //check age
    let today = Date()
    @State private var selectedRole: AccountType = .select
    
    let db = Firestore.firestore()
    @State private var errorMessage: String = ""
    @State private var result: String = "[result]"
    @State private var allUsersResult: String = "No users retrieved yet."
    @State private var soundID = 1543
    @State private var searchFirstName: String = "" // input from user
    
    @State private var pointFullName = 0 //0 means display nothing  🫥
    @State private var pointUsername = 0 //1 means display warning  ⚠️
    @State private var pointPassword = 0 //2 means display success  ✅
    @State private var pointBorn     = 0
    @State private var pointAccountType = 0
    
    @State private var usernameMatching = false
    
    @FocusState private var fullNameIsFocused: Bool
    @FocusState private var usernameIsFocused: Bool
    @FocusState private var passwordIsFocused: Bool
    
    @State private var navigate = false
    
    
    var body: some View {
        //ZStack {Color("BackgroundColor")
        //.edgesIgnoringSafeArea(.all)
        //.allowsHitTesting(false) //lets you type into the text fields
        ScrollView{
            VStack (spacing: 15){
                Spacer()
                Text("Create an account to get started").font(.title.bold()) .foregroundColor(.black.opacity(0.9)) .multilineTextAlignment(.center)
                
                Spacer().frame(height: 20)
                
                //ERROR DISPLAY AT TOP
                if usernameMatching { //print this special aline
                    VStack {
                        Text("The username \"\(user)\" already exists. Please try a different username or")
                            .multilineTextAlignment(.center)
                    
                            NavigationLink("sign in here.") {
                                LogIn(usernameParameter: username)
                            }
                            .underline()
                            .foregroundColor(.blue)
                           
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.black.opacity(0.8))
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.customLightGreen)
                            .shadow(radius: 1)
                    )
                } else if errorMessage != "" { //print other error messages
                    VStack {
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.black.opacity(0.8))
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.customLightGreen)
                            .shadow(radius: 1)
                    )
                }
                
                HStack {
                    TextField("Full Name", text: $full_name)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .focused($fullNameIsFocused)
                        .onChange(of: fullNameIsFocused) { inFocus, offFocus in
                            if !offFocus && full_name != "" {
                                pointFullName = 2 //success
                                errorMessage = "" //reset error message, let you continue
                            }
                        }
                            
                    if pointFullName == 1 {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(Color("CustomOrangeColor"))
                            .font(.title)
                            .bold()
                            .padding(.leading, 10)
                    } else if pointFullName == 2 {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color("CustomGreenColor"))
                            .font(.title)
                            .bold()
                            .padding(.leading, 10)
                    }
                }
                
                HStack {
                    TextField("Username", text: $username)
                        .padding()
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
                                            collectedUserData = "No users found with first name \"\(searchFirstName)\"."
                                            pointUsername = 2 //success
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
                                            pointUsername = 1 //error
                                            usernameMatching = true
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
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        )
                    
                    if pointUsername == 1 {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(Color("CustomOrangeColor"))
                            .font(.title)
                            .bold()
                            .padding(.leading, 10)
                    } else if pointUsername == 2 {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color("CustomGreenColor"))
                            .font(.title)
                            .bold()
                            .padding(.leading, 10)
                    }
                }
                HStack {
                    TextField("Password", text: $password)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .focused($passwordIsFocused)
                        .onChange(of: passwordIsFocused) { inFocus, offFocus in
                            if !offFocus && password != "" {
                                pointPassword = 2 //success
                                errorMessage = "" //reset error message, let you continue
                            }
                        }
                    if pointPassword == 1 {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(Color("CustomOrangeColor"))
                            .font(.title)
                            .bold()
                            .padding(.leading, 10)
                    } else if pointPassword == 2 {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color("CustomGreenColor"))
                            .font(.title)
                            .bold()
                            .padding(.leading, 10)
                    }
                }
                HStack {
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
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    )
                    
                    
                    if pointBorn == 1 {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(Color("CustomOrangeColor"))
                            .font(.title)
                            .bold()
                            .padding(.leading, 10)
                    } else if pointBorn == 2 {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color("CustomGreenColor"))
                            .font(.title)
                            .bold()
                            .padding(.leading, 10)
                    }
                }
                
                HStack {
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
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    )
                    
                    
                    if pointAccountType == 1 {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(Color("CustomOrangeColor"))
                            .font(.title)
                            .bold()
                            .padding(.leading, 10)
                    } else if pointAccountType == 2 {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color("CustomGreenColor"))
                            .font(.title)
                            .bold()
                            .padding(.leading, 10)
                    }
                }
                
                Spacer().frame(height: 20)
                
                Button("Sign up") {
                    errorMessage = "" //resets
                    
                    if full_name == "" {
                        errorMessage += "Please enter your full name. "
                        pointFullName = 1
                    } else {
                        pointFullName = 2
                    }
                    
                    if username == "" || usernameMatching == true {
                        errorMessage += "Please create a username. "
                        pointUsername = 1
                    } else if username != "" && usernameMatching == false {
                        pointUsername = 2
                    }
                    
                    if password == "" {
                        errorMessage += "Please create a password. "
                        pointPassword = 1
                    } else {
                        pointPassword = 2 //since the focus doesnt work that well in use
                    }
                    
                    if Calendar.current.isDate(born, inSameDayAs: today) || born > today {
                        errorMessage += "Please select a valid date of birth. "
                        pointBorn = 1
                    } else {
                        pointBorn = 2
                    }
                    
                    if selectedRole == .select {
                        errorMessage += "Please select a role. "
                        pointAccountType = 1
                    } else {
                        pointAccountType = 2
                    }
                    
                    if errorMessage == "" { //all is clear
                        pointFullName = 2
                        pointUsername = 2
                        pointPassword = 2
                        pointBorn = 2
                        pointAccountType = 2
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
                                
                                //MOVE TO THE NEXT PAGE:
                                navigate = true
                                
                            } catch {
                                print("Error adding document: \(error)")
                            }
                        }
                        AudioServicesPlaySystemSound(1104)
                    }
                    
                    
                    
                    
                }
                .padding()
                .frame(width:200)
                .bold()
                .background(RoundedRectangle(cornerRadius: 50).fill(.darkAccent))
                .foregroundColor(.white)
                
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
        } .navigationDestination(isPresented: $navigate) {
            PatientListView()  // The page it moves to
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
