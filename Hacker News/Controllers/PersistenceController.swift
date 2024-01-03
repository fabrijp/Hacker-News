//
//  PersistenceStorage.swift
//  News
//
//  Created by Alexandre Fabri on 2021/09/21.
//

import Foundation
import Combine

/// Persistence Storage Feature
/// Data serialized is saved into userDefaults
class PersistenceController: ObservableObject {
    
    /* Properties
     
        userDefaults    - The storage method
        settingsKey     - The key for saving settings data
        maxItem         - Maximum items to be saved ( items above this limit will be discated )
        totalItems      - Current number of stories loaded/saved
     
     */
    private let userDefaults: UserDefaults
    private let settingsKey: String = "settings"
    /// Maximum items to be saved ( items above this limit will be discated )
    public var maxItems: Int = 30
    // Current number of stories loaded/saved
    private var totalItems: Int = 0
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
}

extension PersistenceController {
    
    /// Save story to local storage.
    /// If a story already exists, it will be discated otherwise overwrite is specified with `true` value.
    /// - Parameters:
    ///   - story: Story model object
    ///   - storySource: Story source enum
    ///   - storyRead: Flag to update the story state ( read/unread )
    ///   - overwrite: Flag to determine if story will be overwritten in case it already exists
    ///
    func saveStory(story: StoryModel, storySource: StorySource, storyRead: Bool, overwrite: Bool = false) {
        // Get local story from storage
        let localStory = userDefaults.object(forKey: "\(storySource.rawValue)-\(story.id)")
        
        // We have to make sure to have something to update
        if (storyRead || overwrite) && localStory == nil { return }
        if !storyRead && localStory != nil { return }
        
        // save story
        var story = story
        story.read = storyRead
        story.source = storySource
        
        // Update userDefaults
        userDefaults.set(try? PropertyListEncoder().encode(story), forKey: "\(storySource.rawValue)-\(story.id)")
        
        if storySource == .bookmark || storyRead || overwrite { return }
        
        // Apply storage limitation but for Favorites
        if storySource != .bookmark && totalItems + 1 > maxItems {
            let tmpStories = loadStories(storySource: storySource, noCount: true)
            for (index, tmpStory) in tmpStories.enumerated() {
                if index < maxItems {
                    userDefaults.set(try? PropertyListEncoder().encode(tmpStory), forKey: "\(storySource.rawValue)-\(tmpStory.id)")
                } else {
                    removeStory(story: tmpStory, source: storySource)
                }
            }
            totalItems = maxItems
        } else {
            totalItems += 1
        }
    }

    
    func removeStory(story: StoryModel, source: StorySource) {
        guard let storedStory = userDefaults.object(forKey: "\(source.rawValue)-\(story.id)") as? Data,
              let existingStory = try? PropertyListDecoder().decode(StoryModel.self, from: storedStory) else {
            return
        }
        // Check if the existing story's source matches the specified source
        if existingStory.source == source {
            userDefaults.removeObject(forKey: "\(source.rawValue)-\(story.id)")
        }
    }
    
    /// Update a story read state to true
    /// - Parameters:
    ///   - story: The Story model object
    ///   - storySource: The Story source object
    func readStory(story: StoryModel, storySource: StorySource) {
        // We set overwrite 'true' to update current story on local storage.
        saveStory(story: story, storySource: storySource, storyRead: true, overwrite: true)
    }
    
    /// Local all stories from local storage and return it
    /// - Parameter storySource: Story source enum
    /// - Parameter noCount: Flag to update the total of items with number of items loaded
    /// - Returns: Array of Story model in descending date order
    func loadStories(storySource: StorySource, noCount: Bool = false) -> [StoryModel] {
        
        let storyKeys = userDefaults.dictionaryRepresentation().keys.filter { $0.starts(with: "\(storySource.rawValue)-") }
        let stories = storyKeys.compactMap { key in
            userDefaults.object(forKey: key) as? Data
        }.compactMap { data in
            try? PropertyListDecoder().decode(StoryModel.self, from: data)
        }
        
        if !noCount {
            // update total items
            totalItems = stories.count
        }
        
        return stories.sorted(by: { $0.time > $1.time })
    }
    
    /// Save settings to local storage
    /// - Parameter data: Settings model object
    func saveSettings(data:SettingsModel) {
        // Update settings data
        userDefaults.set(try? PropertyListEncoder().encode(data), forKey: settingsKey)
    }
    
    /// Load settings from local storage and return it
    /// - Returns: Settings model object
    func loadSettings() -> SettingsModel {
        if let data = userDefaults.object(forKey: settingsKey) as? Data, let settings = try? PropertyListDecoder().decode(SettingsModel.self, from: data) {
            return settings
        } else {
            // Create and save default settings if nothing is found.
            let defaultSettings = SettingsModel(lastStorySource: .newStories)
            saveSettings(data: defaultSettings)
            return defaultSettings
        }
    }
}
