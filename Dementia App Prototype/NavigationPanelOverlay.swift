//
//  NavigationPanel.swift
//  Dementia App Prototype
//
//  Created by Melissa Lyon on 30/9/2025.
//

import SwiftUI
import FirebaseFirestore

struct NavigationPanelOverlay: View {
    @Environment(\.dismiss) var dismiss
    @Binding var showMenu: Bool
    @StateObject var viewModel = ToDoViewModel.shared
    @State private var uploadSuccess: Bool? = nil
    var usernameParameter: String = "Melyon"
    
    var body: some View {
        
        ZStack {
            HStack { //for the menu itself
                VStack {
                    Spacer() .frame(height: 50) //moves it down from the top
                    
                    Button {
                        showMenu.toggle()
                        print("I pressed dismiss in menu")
                        print(showMenu)
                    } label: {
                        HStack {
                            Spacer().frame(width:20)
                            Image(systemName: "line.horizontal.3")
                                .font(.title2)
                            Text("Menu")
                                .font(.title2)
                            Spacer()
                        } .foregroundColor(.black)
                    }
                    
                    Spacer().frame(height:40)
                    
                    /* These buttons functionalities will be added later (Non-essential for mvp)
                     Button {
                     // destination: CallOptionsPage()
                     } label: {
                     HStack {
                     Spacer().frame(width:20) //away from left wall
                     Text("☎️  Call Options")
                     Spacer()
                     }
                     }
                     .foregroundColor(.black)
                     .font(.title3)
                     
                     
                     Spacer().frame(height:25)
                     
                     Button {
                     // destination: SettingsPage()
                     } label: {
                     HStack {
                     Spacer().frame(width:20) //away from left wall
                     Text("⚙️  Open Settings")
                     Spacer()
                     }
                     }
                     .foregroundColor(.black)
                     .font(.title3)
                     
                     Spacer().frame(height:25)
                     */
                    
                    NavigationLink (destination: DataAndStats())  {
                        HStack {
                            Spacer().frame(width:20) //away from left wall
                            Text("📊  Accounts and Data")
                            Spacer()
                        }
                    }
                    .foregroundColor(.black)
                    .font(.title3)
                    
                    Spacer()
                    
                    HStack {
                        if uploadSuccess == true {
                            // Upload succeeded → show checkmark instead of button
                            Text("Upload successful") .foregroundColor(.darkGreen)
                            Image(systemName: "checkmark")
                                .foregroundColor(.darkGreen)
                                .font(.title)
                                .bold()
                        } else {
                            // Button is visible if upload hasn't succeeded yet (nil or false)
                            Button("Sync Data") {
                                Task {
                                    let success = await viewModel.uploadAllTasksToFirestore(username: usernameParameter)
                                    uploadSuccess = success
                                    print(success ? "Upload successful" : "Upload failed")
                                }
                            }
                            .foregroundColor(.blue)
                            .underline()
                            
                            // If previous upload failed, also show warning icon next to the button
                            if uploadSuccess == false {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(Color("CustomOrangeColor"))
                                    .font(.title2)
                                    .bold()
                            }
                        }
                    }
                    
                    
                    Spacer() .frame(height:20)
                    //REMOVED HERE
                }
                .background(.ultraThinMaterial) //adds the nice frosted background.
                
                Spacer()
                    .frame(maxHeight: .infinity)
                    .frame(width: 150)
            } .ignoresSafeArea(.all)
            
            HStack {
                Spacer()
                Button {
                    showMenu.toggle()
                    print("I pressed dismiss on the right")
                    print(showMenu)
                } label: {
                    Rectangle() //for the invisible button on the right that will exit the menu bar
                        .fill(Color.clear)
                        .frame(maxHeight: .infinity)
                        .frame(width: 150)
                }
            } .ignoresSafeArea(.all)
        }
    }
}

#Preview {
//    NavigationPanelOverlay() 
}
