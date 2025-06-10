//
//  CharacterServiceProtocol.swift
//  ios-marvel
//
//  Created by Jose Julio Junior on 10/06/25.
//

import Foundation

protocol CharacterServiceProtocol {
    func fetchCharacters(offset: Int, limit: Int, nameStartsWith: String?, completion: @escaping (Result<[Character], NetworkError>) -> Void)
}

class CharacterService: CharacterServiceProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }
    
    func fetchCharacters(offset: Int = 0, limit: Int = 20, nameStartsWith: String? = nil, completion: @escaping (Result<[Character], NetworkError>) -> Void) {
        let url = MarvelAPI.charactersEndpoint(offset: offset, limit: limit, nameStartsWith: nameStartsWith)
        
        apiClient.fetch(url: url) { (result: Result<CharacterDataWrapper, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response.data.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
