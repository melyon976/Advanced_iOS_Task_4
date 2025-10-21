//
//  TaskWidgetBundle.swift
//  TaskWidget
//
//  Created by Grace on 21/10/2025.
//

import WidgetKit
import SwiftUI

@main
struct TaskWidgetBundle: WidgetBundle {
    var body: some Widget {
        TaskWidget()
        TaskWidgetControl()
        TaskWidgetLiveActivity()
    }
}
