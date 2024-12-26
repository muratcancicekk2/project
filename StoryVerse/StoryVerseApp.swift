//
//  StoryVerseApp.swift
//  StoryVerse
//
//  Created by Murat Çiçek on 15.12.2024.
//

import SwiftUI

@main
struct StoryVerseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
