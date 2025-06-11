//
//  MockCharacterService.swift
//  ios-marvel
//
//  Created by Jose Julio Junior on 11/06/25.
//

@testable import ios_marvel

class MockCharacterService: CharacterServiceProtocol {
    var mockCharacters: [Character] = []
    var mockError: NetworkError?
    var loadCharactersCalled = false
    
    func fetchCharacters(offset: Int, limit: Int, nameStartsWith: String?, completion: @escaping (Result<[Character], NetworkError>) -> Void) {
        loadCharactersCalled = true
        
        if let error = mockError {
            completion(.failure(error))
        } else {
            completion(.success(mockCharacters))
        }
    }
}
