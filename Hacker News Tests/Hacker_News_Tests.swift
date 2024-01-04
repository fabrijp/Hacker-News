//
//  Hacker_NewsTests.swift
//  Hacker NewsTests
//
//  Created by Alexandre Fabri on 2021/09/27.
//

@testable import Hacker_News
import XCTest

class Hacker_NewsTests: XCTestCase {
    
    var storyController: testAPI!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        storyController = testAPI()
        // Our local mock data contains 11 items for both story sources.
        // Setting the maxItems to 10 to test the limitation.
        storyController.api.maxItems = 10
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        storyController = nil
    }
    
    // Test StoryController methods
    func testStoryController() throws {
        
        // Create and set story source
        var storySource: StorySource = .newStories
        
        // Prepare expectations
        var expectations: [XCTestExpectation] = []
        expectations.append(XCTestExpectation(description: "Download from \(String(describing: storySource))"))
        expectations.append(XCTestExpectation(description: "Download 10 articles from \(String(describing: storySource))"))
        expectations.append(XCTestExpectation(description: "Save 10 articles from \(String(describing: storySource))"))
        // Set expectations
        storyController.expectations = expectations
        // Retrieve stories ( there are more tests inside this method )
        storyController.retrieveNewStories(from: storySource)
        // Test expectations
        wait(for: storyController.expectations, timeout: 5.0)
        
        // Retrieve top stories
        // Prepare expectations
        expectations[0] = XCTestExpectation(description: "Download from \(String(describing: storySource))")
        expectations[1] = XCTestExpectation(description: "Download 10 articles from \(String(describing: storySource))")
        expectations[2] = XCTestExpectation(description: "Save 10 articles from \(String(describing: storySource))")
        // Set story source
        storySource = .topStories
        // Set expectations
        storyController.expectations = expectations
        // Retrieve stories ( there are more tests inside this method )
        storyController.retrieveNewStories(from: storySource)
        // Test expectations
        wait(for: storyController.expectations, timeout: 5.0)
        
        // Unread stories
        // Set story source
        storySource = .newStories
        // Load stories and set unread ones
        storyController.loadLocalStories(from: storySource)
        // Test result
        XCTAssertEqual(storyController.unreadStories, storyController.api.maxItems)
        // Set story source
        storySource = .topStories
        // Load stories and set unread ones
        storyController.loadLocalStories(from: storySource)
        // Test result
        XCTAssertEqual(storyController.unreadStories, storyController.api.maxItems)
        
        // Read one story
        // Set story source
        storySource = .newStories
        // Load stories and set unread ones
        storyController.loadLocalStories(from: storySource)
        // Set first story to read state
        storyController.readStory(story: storyController.stories[0])
        // Test result
        XCTAssertEqual(storyController.unreadStories, storyController.api.maxItems - 1)
        
        // Read all stories
        // Set story source
        storySource = .topStories
        // Load stories and set unread ones
        storyController.loadLocalStories(from: storySource)
        // Set all stories to read state
        storyController.readAllStories(from: storySource)
        // Test result
        XCTAssertEqual(storyController.unreadStories, 0)
        
    }
    
}

extension Hacker_NewsTests {
    
    // We are interested to test the API results and some controllers methods that modify the displayed data.
    // The persistence are using userDefaults for storage. Speaking personally, I wouldn’t write a unit test for that code.
    // When you spend time writing test code, you want to focus on testing things that are likely to fail.
    class testAPI: StoryController {
        
        // Test properties
        var expectations: [XCTestExpectation] = []
        
        override func retrieveNewStories(from storySource: StorySource) {
            // Reset stories
            stories.removeAll()
            // Fetch news stories ID from JSON file
            let testSourceLocalFile = Bundle(for: type(of: self)).url(forResource: "newstories".lowercased(), withExtension: "json")!
            api.allStoriesId(endPoint: testSourceLocalFile)
                .sink { resp in
                    switch resp {
                        case .failure(_): XCTFail()
                        case .finished: self.expectations[0].fulfill()
                    }
                } receiveValue: { newIds in
                    // We have only 11 story json files
                    XCTAssertEqual(newIds.count, 11)
                    // Iterate all new story Ids limited by a max item number
                    for id in newIds.prefix(self.api.maxItems) {
                        let testStoryLocalFile = Bundle(for: type(of: self)).url(forResource: "\(id)", withExtension: "json")!
                        // Fetch the story from from JSON file
                        self.api.story(endPoint: testStoryLocalFile)
                            .sink { resp in
                                switch resp {
                                    case .failure(_): XCTFail()
                                    case .finished: self.expectations[1].fulfill()
                                }
                            } receiveValue: { story in
                                // Set custom properties
                                var story = story
                                story.read = false
                                // Test custom property
                                XCTAssertEqual(story.read, false)
                                // Test if received story matches the requested one
                                XCTAssertEqual(story.id, id)
                                // Save story
                                self.stories.append(story)
                                
                                if self.stories.count == self.api.maxItems {
                                    // Test if we have 10 saved stories
                                    self.expectations[2].fulfill()
                                }
                            }
                            .store(in: &self.cancellable)
                    }
                    
                }
                .store(in: &cancellable)
        }
        
        // override to remove persistence call only
        override func loadLocalStories(from storySource: StorySource) {
            // Set unread stories
            unreadStories = stories.filter { $0.read == false }.count
        }
        
        // override to remove persistence call only
        // - Parameter story: Story model
        override func readStory(story: StoryModel) {
            guard story.read == false else { return }
            // Update `stories` and `unreadStories` property
            if let index = self.stories.firstIndex(where: {$0.id == story.id}) {
                self.stories[index].read = true
                self.unreadStories-=1
            }
        }
        
    }
    
}
