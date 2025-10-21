//
//  WidgetView.swift
//  Dementia App Prototype
//
//  Created by Grace on 21/10/2025.
//
import SwiftUI

struct WidgetView : View {
    var entry: TaskProvider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text("Next Task")
                .font(.headline)
            Text(entry.taskName)
                .font(.title2)
                .bold()
            Text("at \(entry.taskTime)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
    }
}
