//
//  MockUserDefaults.swift
//  ios-marvel
//
//  Created by Jose Julio Junior on 11/06/25.
//

import Foundation

class MockUserDefaults: UserDefaults {
    var mockStore: [String: Any] = [:]
    
    override func data(forKey defaultName: String) -> Data? {
        return mockStore[defaultName] as? Data
    }
    
    override func set(_ value: Any?, forKey key: String) {
        mockStore[key] = value
    }
}
