//
//  PersistenceControllerProtocol.swift
//  Hacker News
//
//  Created by Alexandre Fabri on 2024/01/05.
//

import Foundation

/**
 `PersistenceControllerProtocol` defines the interface for a storage controller, outlining methods for managing story and settings data persistence.
 */
protocol PersistenceControllerProtocol {
    
    /**
     Saves a story to the storage.
     
     - Parameters:
     - story: The story to be saved.
     - storySource: The source of the story.
     - storyRead: A boolean indicating whether the story has been read.
     - overwrite: A boolean indicating whether to overwrite an existing story with the same identifier.
     */
    func saveStory(story: StoryModel, storySource: StorySource, storyRead: Bool, overwrite: Bool)
    
    /**
     Removes a story from the storage.
     
     - Parameters:
     - story: The story to be removed.
     - source: The source of the story.
     */
    func removeStory(story: StoryModel, source: StorySource)
    
    /**
     Marks a story as read in the storage.
     
     - Parameters:
     - story: The story to be marked as read.
     - storySource: The source of the story.
     */
    func readStory(story: StoryModel, storySource: StorySource)
    
    /**
     Loads stories from the storage based on the specified source.
     
     - Parameters:
     - storySource: The source from which stories should be loaded.
     - noCount: A boolean indicating whether to load stories without counting them in the unread stories count.
     
     - Returns: An array of loaded stories.
     */
    func loadStories(storySource: StorySource, noCount: Bool) -> [StoryModel]
    
    /**
     Saves application settings to the storage.
     
     - Parameter data: The settings data to be saved.
     */
    func saveSettings(data: SettingsModel)
    
    /**
     Loads application settings from the storage.
     
     - Returns: The loaded settings data.
     */
    func loadSettings() -> SettingsModel
}

