//
//  Environment.swift
//  NewsFeed
//
//  Created by Luka Šalipur on 2. 3. 2026..
//

import Foundation


public enum Environment {
    enum Keys {
        static let apiKey = "API_KEY"
    }
    
    // Getting plist file
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("plist file not found")
        }
        return dict
    }()
    
    static let apiKey: String = {
        guard let apiKeyString = Environment.infoDictionary[Keys.apiKey] as? String else {
            fatalError("API Key is not set in plist")
        }
        return apiKeyString
    }()
}
