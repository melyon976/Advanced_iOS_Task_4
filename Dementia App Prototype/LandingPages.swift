//
//  LandingPages.swift
//  Dementia App Prototype
//
//  Created by Melissa Lyon on 27/8/2025.
//

import SwiftUI
import FirebaseFirestore

var role: String = ""

// MARK: - LandingPage 1
struct LandingPage1: View {
    var body: some View {
        NavigationStack {
            ZStack{
                Color(.black)
                    .ignoresSafeArea()
                
                Image("LandingPage1")
                    .resizable()
                    .frame(width: 580, height:920)
                    .opacity(0.85)
                
                VStack {
                    Text("Welcome to")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .bold()
                        .shadow(radius: 5)
                    Text("Remora")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .bold()
                        .shadow(radius: 5)
                    Text("A memory aided app for everyday needs and supported by family")
                        .foregroundColor(.white.opacity(0.9))
                        .frame(width: 400)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                        .frame(height:200)
                    NavigationLink("Next", destination: LandingPage2())
                        .frame(width: 100, height: 50)
                        .background(Color.white.opacity(0.8))
                        .foregroundColor(.black)
                        .cornerRadius(18)
                        .shadow(radius: 5)
                }
            } .navigationBarBackButtonHidden(true)
        }
    }
}

// MARK: - LandingPage 2
struct LandingPage2: View {
    var body: some View {
        
        ZStack{
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            VStack {
                Button(action: {
                    print("Image button tapped!")
                }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(.cyan)
                        .font(.title)
                        .frame(width: 60, height: 60)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(50)
                }
                Spacer()
                    .frame(height: 600)
            }
            VStack{
                Spacer()
                    .frame(height: 150)
                Text("About This App")
                    .font(.title)
                Spacer()
                    .frame(height: 30)
                
                Text("This app is designed to help people with early to mid-stage dementia manage daily tasks at home. You can pick the people who can view insights and provide the right support for you. And don’t worry all your data remains private and fully under your control.\n")
                    .multilineTextAlignment(.center)
                
                (Text("This app is") +
                 Text(" not ").italic() +
                 Text("meant for those with late or severe dementia, who need professional medical care.")
                ) .multilineTextAlignment(.center)
                
                Spacer()
                
            } .padding(.horizontal, 30)
            VStack{
                Spacer()
                    .frame(height:350)
                NavigationLink("Begin", destination: LogIn()) //would be LandingPage3()
                    .frame(width: 100, height: 50)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(18)
            }
        }
    }
}

// MARK: - LandingPage 3
struct LandingPage3: View {
    
    @State var selectPatient = false
    @State var selectCaregiver = false
    @State var selectDoctor = false
    
    var body: some View {
        ZStack{
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack{
                Spacer()
                    .frame(height: 200)
                Text("Tell us a bit about yourself")
                    .font(.title)
                Spacer()
                    .frame(height: 40)
                
                Text("What is your role?")
                    .font(.headline)
                
                Spacer()
                    .frame(height: 20)
                
                Button(action: {
                    selectPatient = true
                    selectCaregiver = false
                    selectDoctor = false
                    role = "patient"
                    print(role)
                }) {
                    Text("Person with early stage Dementia")
                        .frame(width: 320, height: 50)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(18)
                        .overlay(
                            Group {
                                if selectPatient {
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.blue, lineWidth: 2)
                                }
                            }
                        )
                }
                
                Spacer()
                    .frame(height: 12)
                
                Button(action: {
                    selectPatient = false
                    selectCaregiver = true
                    selectDoctor = false
                    role = "caregiver"
                    print(role)
                }) {
                    Text("Family or Caregiver")
                        .frame(width: 320, height: 50)
                        .background(Color.white)
                        .cornerRadius(18)
                        .foregroundColor(.black)
                        .overlay(
                            Group {
                                if selectCaregiver {
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.blue, lineWidth: 2)
                                }
                            }
                        )
                }
                
                Spacer()
                    .frame(height: 12)
                
                Button(action: {
                    selectPatient = false
                    selectCaregiver = false
                    selectDoctor = true
                    role = "doctor"
                    print(role)
                }) {
                    Text("GP or specialist")
                        .frame(width: 320, height: 50)
                        .background(Color.white)
                        .cornerRadius(18)
                        .foregroundColor(.black)
                        .overlay(
                            Group {
                                if selectDoctor {
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.blue, lineWidth: 2)
                                }
                            }
                        )
                }
                
                Spacer()
                    .frame(height: 50)
                
                if selectPatient || selectCaregiver || selectDoctor {
                    NavigationLink("Next", destination: LandingPage4())
                } else {
                    //
                }
                Spacer()
            }
        }
    }
}

// MARK: - LandingPage 4
struct LandingPage4: View {
    @State var fullName: String = ""
    @State var phoneNumber: Int = 0
    @State var curStageDementia: String = ""
    @State var medNotes: String = ""
    
    var body: some View {
        ZStack{
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack{
                Spacer()
                    .frame(height: 200)
                Text("Tell us a bit about yourself")
                    .font(.title)
                Spacer()
            }
        }
    }
}


#Preview {
    LandingPage1()
}
