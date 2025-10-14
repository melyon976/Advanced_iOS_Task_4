import SwiftUI
import FirebaseFirestore
import AudioToolbox

struct ListItem: View {
    @ObservedObject var viewModel: ToDoViewModel = .shared
    let db = Firestore.firestore()
    var index: Int
    
    private var relativeFormatter: RelativeDateTimeFormatter {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .short  // gives "in 4 hr"
        return f
    }

    var body: some View {
        NavigationLink(destination: DetailView(toDoIndex: index)) {
            HStack {
                
                Button(action: {
                    viewModel.toDos[index].checked.toggle()
                    
                    if viewModel.toDos[index].checked {
                        AudioServicesPlaySystemSound(1504)
                        Task {
                            do {
                                try await db.collection("users")
                                    .document("kjEt5qJlQoBUyg6GDkvy")
                                    .updateData([
                                        "tasks_completed": FieldValue.increment(1.0),
                                        "tasks_not_completed": FieldValue.increment(-1.0)
                                    ])
                                print("Marked task as completed.")
                            } catch {
                                print("Error updating document: \(error)")
                            }
                        }
                    } else {
                        Task {
                            do {
                                try await db.collection("users")
                                    .document("kjEt5qJlQoBUyg6GDkvy")
                                    .updateData([
                                        "tasks_completed": FieldValue.increment(-1.0),
                                        "tasks_not_completed": FieldValue.increment(1.0)
                                    ])
                                print("Marked task as incomplete.")
                            } catch {
                                print("Error updating document: \(error)")
                            }
                        }
                    }
                }) {
                    Image(systemName: viewModel.toDos[index].checked ? "checkmark.square.fill" : "square")
                        .font(.title)
                        .foregroundColor(viewModel.toDos[index].checked ? Color("DarkGreenColor") : .gray)
                }

                Spacer().frame(width: 15)

                VStack(alignment: .leading, spacing: 5) {
                    Text(viewModel.toDos[index].itemName)
                        .font(.headline)
                        .lineLimit(2)
                    
                    if let desc = viewModel.toDos[index].desc {
                        Text(desc)
                            .lineLimit(2)
                            .truncationMode(.tail)
                    }

                    // Displays relative time
                    Text("(\(relativeFormatter.localizedString(for: viewModel.toDos[index].when, relativeTo: Date())))")
                        .font(.subheadline)
                        .foregroundColor(
                            viewModel.toDos[index].when.timeIntervalSinceNow <= 3600 && !viewModel.toDos[index].checked
                                ? .orange //due 1 hour or less
                                : .gray //otherwise gray
                            )
                }

                Spacer()

                Image(viewModel.toDos[index].imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(radius: 5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    // Sample item for preview
    

    return ListItem(index: 0)
}
