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
        let urlString = "\(thumbnail.path).\(thumbnail.extension)"
        
        guard var components = URLComponents(string: urlString) else {
            return nil
        }
        
        components.scheme = "https"
        return components.url
    }
}

struct Thumbnail: Codable {
    let path: String
    let `extension`: String
}

extension Character {
    func toData() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
    static func fromData(_ data: Data) -> Character? {
        return try? JSONDecoder().decode(Character.self, from: data)
    }
}
