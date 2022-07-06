import Security
import UIKit

public class KeyChainData {
    public static var instance = KeyChainData()
    public func saveKeychainData(key: String, value: String) {
        let data = value.data(using: .utf8)!
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
        ]

        // Add User Data
        if SecItemAdd(attributes as CFDictionary, nil) == noErr {
            print("Data saved in keychain with encryption")
        } else {
            print("Data already save in KeyChain or Something went wrong!")
        }
    }
    public func fetchKeychainData(key: String) -> String? {
        // Set query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true,
        ]
        var item: CFTypeRef?

        // Check if user exists in the keychain
        if SecItemCopyMatching(query as CFDictionary, &item) == noErr {
            // Extract result
            if let existingItem = item as? [String: Any],
               let valueData = existingItem[kSecValueData as String] as? Data,
               let value = String(data: valueData, encoding: .utf8)
            {
                return value
            } else { return nil }
        } else {
            print("Something went wrong trying to find the user in the keychain")
            return nil
        }
    }
    public func clearKeyChainData(key: String) {
        // Set query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
        ]

        // Find user and delete
        if SecItemDelete(query as CFDictionary) == noErr {
            print("User removed successfully from the keychain")
        } else {
            print("Something went wrong trying to remove the user from the keychain")
        }
    }
}

