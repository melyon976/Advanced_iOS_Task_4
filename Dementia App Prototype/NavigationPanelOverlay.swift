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
    
    var body: some View {
        
        ZStack{
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
                    
                    NavigationLink (
                        destination: DataAndStats())  {
                        HStack {
                            Spacer().frame(width:20) //away from left wall
                            Text("📊  Accounts and Data")
                            Spacer()
                        }
                    }
                        .foregroundColor(.black)
                        .font(.title3)
                    Spacer()
                }
                .background(.ultraThinMaterial) //adds the nice frosted background.
                
                Spacer()
                    .frame(maxHeight: .infinity)
                    .frame(width: 150)
            } .ignoresSafeArea(.all)
            HStack{
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
