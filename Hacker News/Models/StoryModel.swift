//
//  Story.swift
//  News
//
//  Created by Alexandre Fabri on 2021/09/21.
//

import Foundation

/// Hacker News story properties we are interested to support.
/// More info: https://github.com/HackerNews/API
public struct StoryModel: Codable, Identifiable {
    // Fields this app will support
    // Consult HN API documentation for details
    public let id: Int
    public let title: String
    public let by: String
    public let time: TimeInterval
    public let score: Int
    public let url: String
    // Custom internal property.
    // Flag read stories by the user
    public var read: Bool?
    // Bookmark
    public var bookmark: Bool? = nil
    // Source
    public var source: StorySource? = nil
}
