//
//  Hacker_NewsApp.swift
//  Hacker News
//
//  Created by Alexandre Fabri on 2021/09/27.
//

import SwiftUI

@main
struct Hacker_NewsApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .navigationTitle("Hacker News")
            }
            .navigationViewStyle(.stack)
        }
    }
}
