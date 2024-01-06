//
//  StoryControllerProtocol.swift
//  Hacker News
//
//  Created by Alexandre Fabri on 2024/01/05.
//

import Foundation

/**
 `StoryControllerProtocol` provides the interface intended for use by the `StoryController` class.
 */
protocol StoryControllerProtocol  {
    
    /* Properties */
    
    /**
     Represents the array of stories retrieved from the API.
     */
    var stories: [StoryModel] { get set }
    
    /**
     Represents the count of current unread stories for the selected story source.
     */
    var unreadStories: Int { get set }
    
    /**
     Represents an optional error condition that may occur during the retrieval of stories from the API.
     */
    var fetchError: HackerNewsAPI.APIFailureCondition? { get set }
    
    /* Methods */
    
    /**
     Retrieves new stories from the API based on the specified story source and saves them to storage.
     
     - Parameter storySource: The source from which stories should be retrieved.
     */
    func retrieveNewStories(from storySource: StorySource)
    
    /**
     Loads stories from storage based on the specified story source.
     
     - Parameter storySource: The source from which stories should be loaded.
     */
    func loadLocalStories(from storySource: StorySource)
    
    /**
     Marks a specific story as read.
     
     - Parameter story: The story to be marked as read.
     */
    func readStory(story: StoryModel)
    
    /**
     Marks all stories from the specified story source as read.
     
     - Parameter storySource: The source from which all stories should be marked as read.
     */
    func readAllStories(from storySource: StorySource)
    
    /**
     Sorts the stories based on their scores in either ascending or descending order.
     
     - Parameter topScore: If `true`, stories will be sorted in descending order (highest score first); otherwise, in ascending order (lowest score first).
     */
    func sortByScore(_ topScore: Bool)
    
}
