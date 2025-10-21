//
//  TaskWidget.swift
//  Dementia App Prototype
//
//  Created by Grace on 21/10/2025.
//

import SwiftUI
import Foundation
import WidgetKit

struct TaskEntry: TimelineEntry {
    let date: Date
    let taskName: String
    let taskTime: String
}

struct TaskProvider: TimelineProvider {
    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(date: Date(), taskName: "Walk the dog", taskTime: "4:30 PM")
    }

    func getSnapshot(in context: Context, completion: @escaping (TaskEntry) -> ()) {
        let entry = TaskEntry(date: Date(), taskName: "Walk the dog", taskTime: "4:30 PM")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskEntry>) -> ()) {
        // You can fetch from Firestore or UserDefaults here
        let entry = TaskEntry(date: Date(), taskName: "Take medication", taskTime: "8:00 AM")
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}
