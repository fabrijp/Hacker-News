//
//  PersistenceControllerProtocol.swift
//  Hacker News
//
//  Created by Alexandre Fabri on 2024/01/05.
//

import Foundation

// Protocol for the storage controller dependency
protocol PersistenceControllerProtocol {
    func saveStory(story: StoryModel, storySource: StorySource, storyRead: Bool, overwrite: Bool)
    func removeStory(story: StoryModel, source: StorySource)
    func readStory(story: StoryModel, storySource: StorySource)
    func loadStories(storySource: StorySource, noCount: Bool) -> [StoryModel]
    func saveSettings(data:SettingsModel)
    func loadSettings() -> SettingsModel
}
