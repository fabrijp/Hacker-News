//
//  HackerNewsApiProtocol.swift
//  Hacker News
//
//  Created by Alexandre Fabri on 2024/01/05.
//

import Combine
import Foundation

/**
 `HackerNewsApiProtocol` defines the interface for an API controller, outlining methods for retrieving Hacker News stories and additional properties for managing API-related information.
 */
protocol HackerNewsApiProtocol {
    
    /**
     Retrieves the IDs of all Hacker News stories from the specified API endpoint.
     
     - Parameter endPoint: The URL endpoint for retrieving all story IDs.
     
     - Returns: A publisher emitting an array of story IDs or an error.
     */
    func allStoriesId(endPoint: URL) -> AnyPublisher<[Int], Error>
    
    /**
     Retrieves a Hacker News story based on the specified API endpoint.
     
     - Parameter endPoint: The URL endpoint for retrieving a specific story.
     
     - Returns: A publisher emitting a `StoryModel` or an error.
     */
    func story(endPoint: URL) -> AnyPublisher<StoryModel, Error>
    
    /**
     Represents the maximum number of items supported by the Hacker News API.
     */
    var maxItems: Int { get }
}
