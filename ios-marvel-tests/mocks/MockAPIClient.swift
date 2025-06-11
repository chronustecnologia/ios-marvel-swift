//
//  MockAPIClient.swift
//  ios-marvel
//
//  Created by Jose Julio Junior on 11/06/25.
//

import Foundation
@testable import ios_marvel

class MockAPIClient: APIClient {
    var mockResult: Result<CharacterDataWrapper, NetworkError>?
    
    override func fetch<T>(url: URL?, completion: @escaping (Result<T, NetworkError>) -> Void) where T : Decodable {
        guard let mockResult = mockResult as? Result<T, NetworkError> else {
            fatalError("Mock result not set")
        }
        completion(mockResult)
    }
}
