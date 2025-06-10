//
//  DataResponse.swift
//  ios-marvel
//
//  Created by Jose Julio Junior on 10/06/25.
//

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
