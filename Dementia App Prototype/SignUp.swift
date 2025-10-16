//
//  SignUp.swift
//  Dementia App Prototype
//
//  Created by Melissa Lyon on 16/10/2025.
//

import SwiftUI

enum AccountType: String, CaseIterable, Identifiable {
    case patient = "Patient"
    case carer = "Carer"
    case doctor = "Doctor"
    case other = "Other"
    
    var id: String { self.rawValue }
}

struct SignUp: View {
    @State private var username: String = "" //verify non-matching
    @State private var password: String = ""
    @State private var given_name: String = ""
    @State private var family_name: String = ""
    @State private var year_of_birth: Date = Date() //check age
    @State private var selectedRole: AccountType = .patient
    
    
    @State private var errorMessage: String = ""
    
    var body: some View {
        ZStack {Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)
            VStack (spacing: 15){
                Text("Create an account to get started").font(.title.bold()) .foregroundColor(.black.opacity(0.9)) .multilineTextAlignment(.center)
                
                
                TextField("First name", text: $given_name)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(radius: 1)
                    )
                
                TextField("Surname", text: $family_name)
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
                    DatePicker("Select Date", selection: $year_of_birth, displayedComponents: [.date])
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .padding(.horizontal)
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
                    .padding(.horizontal)
                    
                    
                } .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                    //                        .stroke(Color.black.opacity(0.5), lineWidth: 1)
                        .shadow(radius: 1)
                )
                
                Button("Sign up") {
                    //add save functionality
                }
                .padding()
                .frame(width:200)
                .bold()
                .background(RoundedRectangle(cornerRadius: 50).fill(.darkAccent))
                .foregroundColor(.white)
            } .padding(.horizontal)
        }
    }
}

struct SignUp2: View {
    var body: some View {
        
    }
}


#Preview {
    SignUp()
}
