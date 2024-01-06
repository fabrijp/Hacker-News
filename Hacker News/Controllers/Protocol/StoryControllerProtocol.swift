//
//  StoryControllerProtocol.swift
//  Hacker News
//
//  Created by Alexandre Fabri on 2024/01/05.
//

import Foundation

/**
 StoryControllerProtocol provides the interface that is
 intended for use by `StoryController` class.
 */
protocol StoryControllerProtocol  {
    
    /* Properties
     
     stories         - Receives retrieved stories from API.
     unreadStories   - Holds the current unread stories for selected story source.
     fetchError      - Will be set when errors occurs while retrieving stories from API.
     
     */
    var stories: [StoryModel] { get set }
    var unreadStories: Int { get set }
    var fetchError: HackerNewsAPI.APIFailureCondition? { get set }
    
    /* Methods
     
     retrieveNewStories     - Retrieve stories from API based on story source set and save to storage.
     loadLocalStories       - Load stories from storage based on story source set.
     readStory              - Will be set when errors occurs while retrieving stories from API.
     sortByScore            - Holds the selected story source. Affects when retrieving stories from API.
     
     */
    func retrieveNewStories(from storySource: StorySource)
    func loadLocalStories(from storySource: StorySource)
    func readStory(story: StoryModel)
    func readAllStories(from storySource: StorySource)
    func sortByScore(_ topScore:Bool)
    
}
