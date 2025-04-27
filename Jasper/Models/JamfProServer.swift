//
//  JamfProServer.swift
//  Jasper
//
//  Created by Bryson Tyrrell on 8/7/24.
//

import SwiftData
import SwiftUI

@Model
class JamfProServer {
    var hostname: String
    var port: Int = 443
    var clientId: String
    
    var themeColorRGB: ThemeColorRGB

    
    @Relationship(deleteRule: .cascade, inverse: \Search.server) var searches = [Search]()
    
    @Transient internal var _client: JamfProAPIClient? = nil

    var clientSecret: String {
        getClientSecretFromKeychain()
    }
    
    var client: JamfProAPIClient {
        guard let client = _client else {
            _client = JamfProAPIClient(
                hostname: hostname,
                port: port,
                clientID: clientId,
                clientSecret: clientSecret
            )
            return _client!
        }
        return client
    }
    
    init(
        hostname: String,
        port: Int,
        clientId: String,
        clientSecret: String,
        themeColor: Color,
        isFavorite: Bool
    ) {
        let themeColorComponents = UIColor(themeColor).cgColor.components
        
        self.hostname = hostname
        self.port = port
        self.clientId = clientId

        self.themeColorRGB = ThemeColorRGB(
            red: Double(themeColorComponents![0]),
            green: Double(themeColorComponents![1]),
            blue: Double(themeColorComponents![2])
        )
        
        self.searches = [
            .init(name: "All Computers", searchType: .computer),
            .init(name: "All Mobile Devices", searchType: .mobileDevice)
        ]
        
        saveClientSecretToKeychain(clientSecret)
    }
    
    private func saveClientSecretToKeychain(_ secret: String) {
            let keychainQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: clientId, // Use clientId as the account identifier
                kSecAttrService as String: hostname, // Use hostname as the service identifier
                kSecValueData as String: secret.data(using: .utf8)!
            ]
            
            // Delete any existing item before adding a new one
            SecItemDelete(keychainQuery as CFDictionary)
            
            // Add new keychain item
            let status = SecItemAdd(keychainQuery as CFDictionary, nil)
            
            if status != errSecSuccess {
                print("Error saving client secret to Keychain: \(status)")
            }
            print("Client secret saved to Keychain for \(hostname) with ID \(clientId)")
        }
        
    private func getClientSecretFromKeychain() -> String {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: clientId,
            kSecAttrService as String: hostname,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        
        let status = SecItemCopyMatching(keychainQuery as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let retrievedData = dataTypeRef as? Data, let secret = String(data: retrievedData, encoding: .utf8) {
            print("Successfully retrieved client secret from Keychain for \(hostname) with ID \(clientId)")
            return secret
        } else {
            print("Error retrieving client secret from Keychain: \(status)")
            return ""
        }
    }
}

struct ThemeColorRGB: Codable {
    let red: Double
    let green: Double
    let blue: Double
}
