import SwiftUI
import FirebaseFirestore
import AudioToolbox
import UserNotifications


// MARK: - Patient List View
struct PatientListView: View {
    @State private var refreshID = UUID() //dummy refresh
    @StateObject var viewModel = ToDoViewModel.shared
    @State var showMenu = false
    @State private var allCompletedPlayed = false
    
    var usernameParameter: String = "Melyon"
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColor")
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer() .frame(height: 50) //moves it down from the top
                    
                    HStack{
                        Button {
                            showMenu.toggle() //toggle menu or not
                            print(showMenu)
                        } label: {
                            
                            Spacer().frame(width:20) //making the clickable area bigger
                            Image(systemName: "line.horizontal.3")
                                .font(.title2)
                            Text("Menu")
                                .font(.title2)
                            
                            Spacer().frame(width:20) //making the clickable area bigger
                        } .foregroundColor(.darkAccent)
                        Spacer()
                    }
                    
                    Spacer() .frame(height: 20) //moves it down from the top
                    HStack {
                        Text("To Do List")
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                        NavigationLink(destination: AddTaskView()) {
                            Text("+ Add Task")
                                .foregroundColor(.black)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 50)
                                        .fill(Color("AccentColor"))
                                        .shadow(radius: 5)
                                )
                        }
                    } .padding(.horizontal)
                    ScrollView {
                        VStack(spacing: 15) {
                            if viewModel.toDos.filter({ $0.present }).allSatisfy({ $0.checked }) {
                                // all present (non-deleted) todos are completed
                                AllCompletedView()
                            }
                            ForEach(viewModel.toDos.indices.sorted {
                                !viewModel.toDos[$0].checked && viewModel.toDos[$1].checked
                            }, id: \.self) { index in
                                if viewModel.toDos[index].present {
                                    ListItem(viewModel: viewModel, index: index)
                                }
                            }
                            .animation(.easeInOut, value: viewModel.toDos.map { $0.checked })
                            .onAppear {
                                // Print the current toDos for debugging
                                print("Rebuilding PatientListView using: " +
                                      viewModel.toDos
                                        .filter { $0.present }     // only keep tasks that are present
                                        .map { $0.itemName }       // extract their names
                                        .joined(separator: ", ")   // join into a single string
                                )

                                // Initialize tasks properly for the user
                                Task {
                                    await viewModel.initializeTasksForUser(username: usernameParameter)
                                }
                            }
                            
                            Button(action:{viewModel.resetToDos()}) {
                                Text("Reset Todos") .foregroundColor(Color("DarkAccentColor").opacity(0))
                            }
                            
                            //MARK: Grace: noti testing
                            Button(action: {
                                NotificationManager.shared.triggerInstantTestNotification()
                            }) {
                                Text("Notification Test")
                                    .foregroundColor(Color("DarkAccentColor").opacity(0))
                            }
                            
                            Button("Load tasks from database") {
                                Task {
                                    await viewModel.loadTasksFromFirestore(username: usernameParameter)
                                }
                            }
                            .opacity(0)

                        }
                        .padding()
                    }
                    .onChange(of: viewModel.toDos.map { $0.checked }) { oldValue, newValue in
                        let allCompleted = viewModel.toDos.filter({ $0.present }).allSatisfy({ $0.checked })
                        if allCompleted {
                            AudioServicesPlaySystemSound(1525)
                        }
                    }
                } .edgesIgnoringSafeArea(.top)
                
                if showMenu {
                    NavigationPanelOverlay(showMenu: $showMenu, usernameParameter: usernameParameter)
                        .transition(.move(edge: .leading)) // slide from left
                } else {
                    //hide menu again
                }
            }
            .animation(.easeInOut(duration: 0.4), value: showMenu) // animation for ZStack level
            .navigationBarBackButtonHidden(true)
        }
        
    }
}

// MARK: - Preview
#Preview {
    PatientListView()
    
    //    let sampleToDo = ToDoItem(id: UUID(), itemName: "Sample Task", checked: false, imageName: "dog")
    //    DetailView(toDoIndex: 1)
    //    EditTaskView(toDoIndex: 1)
    //    AddTaskView()
    //    AllCompletedView()
    //    NavigationBarOverlay()
    //    AllCompletedView()
    //    ZStack{
    //        PatientListView()
    //        NavigationPanelOverlay()
    //    }
}
