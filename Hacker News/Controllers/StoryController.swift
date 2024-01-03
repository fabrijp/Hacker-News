//
//  StoryFetcher.swift
//  News
//
//  Created by Alexandre Fabri on 2021/09/22.
//

import Foundation
import Combine
import SwiftUI

/// Story Source Enum defines constants that can be used to specify
/// the story souce chosen within the app.
///
///    `newStories` - Will return the new stories title string
///
///    `topStories` - Will return the top stories title string
///
///    `func endPointConversion`  - Bridges the Hacker **HackerNewsAPI.EndPoint** returning its source URL
///
public enum StorySource: String, CaseIterable, Codable {
    
    case newStories = "Recent News"
    case topStories = "Top News"
    case bookmark = "Bookmark"
    
    // Convenient bridge from API endpoints
    func endPointConversion() -> HackerNewsAPI.EndPoint? {
        let endpoints: [StorySource: HackerNewsAPI.EndPoint] = [
            .newStories: .newStories,
            .topStories: .topStories
        ]
        
        return endpoints[self]
    }
}

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

/// This class combines ( wrapper ) the Hacker News API and Persistence storage methods
/// to manage all data and key observers.
class StoryController: StoryControllerProtocol, ObservableObject {
    
    /* Protocol properties
     
     stories         - Receives retrieved stories from API.
     unreadStories   - Holds the current unread stories for selected story source.
     fetchError      - Will be set when errors occurs while retrieving stories from API.
     
     */
    @Published var stories: [StoryModel] = []
    @Published var unreadStories: Int = 0
    @Published var fetchError: HackerNewsAPI.APIFailureCondition? = nil
    
    /* Class properties
     
     cancellable     - A type-erasing cancellable object used when retrieving stories.
     api             - The Hacker News API instance.
     localStorage    - The Persistence storage instance.
     
     */
    var cancellable = Set<AnyCancellable>()
    let api = HackerNewsAPI()
    let localStorage = PersistenceController()
    
    
    /// Fetch for new stories from selected source and update the `stories` property and
    /// save new stories locally.
    /// - Parameter storySource: Enum that controls the story souce for Hacker News articles
    func retrieveNewStories(from storySource: StorySource) {
        
        if storySource == .bookmark {
            // load bookmark stories from local storage and return
            loadLocalStories(from: storySource)
            return
        }
        
        // unwrap source endpoint
        guard let source = storySource.endPointConversion()?.url else { return }
        
        // Fetch news stories ID from API
        api.allStoriesId(endPoint: source)
            .sink { error in
                switch error {
                    case .failure(_):
                        DispatchQueue.main.async {
                            self.fetchError = .invalidServerResponse
                        }
                    case .finished:
                        DispatchQueue.main.async {
                            self.fetchError = nil
                        }
                }
            } receiveValue: { newIds in
                // Iterate all new story Ids limited by a max item number
                for id in newIds.prefix(self.api.maxItems + self.api.maxItems) {
                    // Fetch the story from API
                    self.api.story(endPoint: HackerNewsAPI.EndPoint.story(id).url)
                        .sink { error in
                            switch error {
                                case .failure(_): self.fetchError = .invalidServerResponse
                                case .finished: break
                            }
                        } receiveValue: { story in
                            // Set custom properties
                            var story = story
                            story.read = false
                            // Save to local storage
                            self.localStorage.saveStory(story: story, storySource: storySource, storyRead: false)
                            // Load all saved stories
                            self.loadLocalStories(from: storySource)
                        }
                        .store(in: &self.cancellable)
                }
                
            }
            .store(in: &cancellable)
        
    }
    
    /// Load stories from local storage and set `stories` and `unreadStories` property
    func loadLocalStories(from storySource: StorySource) {
        withAnimation {
            // Set `stories` property with local storage data
            stories = localStorage.loadStories(storySource: storySource)
        }
        // Set unread stories
        unreadStories = stories.filter { $0.read == false }.count
    }
    
    /// Set a story to read state
    /// - Parameter story: Story model
    func readStory(story: StoryModel) {
        guard story.read == false else { return }
        // Iterate throught all story sources to update the story read state
        // because they may share the same story, ie: New Stories & Top Stories.
        // It's save because readStory method updates based on the Story ID.
        for source in StorySource.allCases {
            localStorage.readStory(story: story, storySource: source)
        }
        // Update `stories` and `unreadStories` property for current story source articles.
        if let index = stories.firstIndex(where: {$0.id == story.id}) {
            withAnimation {
                stories[index].read = true
                unreadStories-=1
            }
        }
    }
    
    func bookmark(story: StoryModel?) {
        guard let story = story else { return }
        guard let favorite = story.bookmark else { return }
        // Update `stories` and `unreadStories` property for current story source articles.
        if let index = stories.firstIndex(where: {$0.id == story.id}) {
            withAnimation {
                stories[index].bookmark = favorite
            }
        }
    }
    
    /// Set all story in `stories` parameter to read state
    func readAllStories(from storySource: StorySource) {
        for story in stories {
            readStory(story: story)
        }
        unreadStories = 0
    }
    
    /// Sort in place stories order between scores and date/time
    /// `true` will sort by score and `false` by date/time (default)
    /// - Parameter topScore: Boolean
    func sortByScore(_ topScore:Bool) {
        withAnimation {
            stories.sort(by: topScore ? { $0.score > $1.score } : { $0.time > $1.time })
        }
    }
    
}
