//
//  QuickFitApp.swift
//  Project Draft
//
//  Created by Gene Sanmillan on 10/20/22.
//

import SwiftUI
import Firebase

@main
struct QuickFitApp: App {
    @StateObject var dayViewModel = DayViewModel()
    
    init() { FirebaseApp.configure() }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dayViewModel)
        }
    }
}
