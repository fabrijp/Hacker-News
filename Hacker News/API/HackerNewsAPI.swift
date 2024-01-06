//
//  API.swift
//  News
//
//  Created by Alexandre Fabri on 2021/09/21.
//

import Foundation
import Combine

/// Hacker News API
///
/// [The Hacker News API on GitHub](https://github.com/HackerNews/API)
/// Contains all the API references and documentation
class HackerNewsAPI {

    /// Maximum stories to be fetched
    var maxItems: Int = 40
    /// Base API URL
    static var baseURL = URL(string: "https://hacker-news.firebaseio.com/v0")!

    /// LocalizedError enumaration for the API
    enum APIFailureCondition: LocalizedError {
        case invalidServerResponse
        var errorDescription: String? {
            switch self {
                case .invalidServerResponse: return "Invalid response from server"
            }
        }
    }

    /// EndPoint Enum defines constants that can be used to specify
    /// the souce URL for Hacker News articles
    enum EndPoint {

        case story(Int)
        case newStories
        case topStories
        
        var url: URL {
            switch self {
                case .story(let id):
                    return baseURL.appendingPathComponent("/item/\(id).json")
                case .newStories:
                    return baseURL.appendingPathComponent("/newstories.json")
                case .topStories:
                    return baseURL.appendingPathComponent("/topstories.json")
            }
        }

    }
    
    /// Retrieve a single story by it's ID
    /// - Parameter id: The story ID to retrieve
    /// - Returns: Story model `StoryModel` and localizes error, if any,
    func story(endPoint:URL) -> AnyPublisher<StoryModel, Error> {
        URLSession.shared
            .dataTaskPublisher(for: endPoint)
            .receive(on: DispatchQueue.main)
            .map{ $0.0 }
            .decode(type: StoryModel.self, decoder: JSONDecoder())
            .catch { _ in
                Empty()
            }
            .eraseToAnyPublisher()
    }
    
    /// Retrieve all stories ID
    /// - Parameter endPoint: The story source enum
    /// - Returns: All available story source IDs
    func allStoriesId(endPoint:URL) -> AnyPublisher<[Int], Error> {
        URLSession.shared.dataTaskPublisher(for: endPoint)
            .map { $0.0 }
            .decode(type: [Int].self, decoder: JSONDecoder())
            .mapError { error in
                APIFailureCondition.invalidServerResponse
            }
            .eraseToAnyPublisher()
    }
    
}

extension HackerNewsAPI: HackerNewsApiProtocol {}
