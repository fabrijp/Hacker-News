//
//  HackerNewsApiProtocol.swift
//  Hacker News
//
//  Created by Alexandre Fabri on 2024/01/05.
//

import Combine
import Foundation

// Protocol for the API dependency
protocol HackerNewsApiProtocol {
    func allStoriesId(endPoint: URL) -> AnyPublisher<[Int], Error>
    func story(endPoint: URL) -> AnyPublisher<StoryModel, Error>
    var maxItems: Int { get }
}
