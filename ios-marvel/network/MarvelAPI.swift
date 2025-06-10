//
//  MarvelAPI.swift
//  ios-marvel
//
//  Created by Jose Julio Junior on 10/06/25.
//

import Foundation
import CryptoKit

struct MarvelAPI {
    private static let baseURL = "https://gateway.marvel.com/v1/public"
    private static let publicKey = "824cbb5bea753fc4e0c4a3b6db7bd2fd"
    private static let privateKey = "6b43ed0206d255a4981f7ec2937f20ce66482ad5"
    
    static func charactersEndpoint(offset: Int = 0, limit: Int = 20, nameStartsWith: String? = nil) -> URL? {
        let timestamp = String(Date().timeIntervalSince1970)
        let hash = generateHash(timestamp: timestamp)
        
        var components = URLComponents(string: "\(baseURL)/characters")
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "apikey", value: publicKey),
            URLQueryItem(name: "ts", value: timestamp),
            URLQueryItem(name: "hash", value: hash),
            URLQueryItem(name: "offset", value: "\(offset)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        if let nameStartsWith = nameStartsWith, !nameStartsWith.isEmpty {
            queryItems.append(URLQueryItem(name: "nameStartsWith", value: nameStartsWith))
        }
        
        components?.queryItems = queryItems
        return components?.url
    }
    
    private static func generateHash(timestamp: String) -> String {
        let combined = timestamp + privateKey + publicKey
        let inputData = Data(combined.utf8)
        let hashedData = Insecure.MD5.hash(data: inputData)
        return hashedData.map { String(format: "%02hhx", $0) }.joined()
    }
}
