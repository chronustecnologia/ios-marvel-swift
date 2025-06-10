//
//  Character.swift
//  ios-marvel
//
//  Created by Jose Julio Junior on 10/06/25.
//

import Foundation

struct Character: Codable {
    let id: Int
    let name: String
    let description: String
    let thumbnail: Thumbnail
    let resourceURI: String
    
    var imageURL: URL? {
        return URL(string: "\(thumbnail.path).\(thumbnail.extension)")
    }
}

struct Thumbnail: Codable {
    let path: String
    let `extension`: String
}

// For persistence
extension Character {
    func toData() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
    static func fromData(_ data: Data) -> Character? {
        return try? JSONDecoder().decode(Character.self, from: data)
    }
}

// Models/DataResponse.swift
struct CharacterDataWrapper: Decodable {
    let code: Int
    let status: String
    let data: CharacterDataContainer
}

struct CharacterDataContainer: Decodable {
    let offset: Int
    let limit: Int
    let total: Int
    let count: Int
    let results: [Character]
}
