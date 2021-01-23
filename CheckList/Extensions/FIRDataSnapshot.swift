//
//  FIRDataSnapshot.swift
//  CheckList
//
//  Created by Владислав on 22.01.2021.
//

import Foundation
import FirebaseDatabase

extension DataSnapshot {
    func decoded<T: Decodable>() throws -> T? {
        guard let value = self.value else {
            return nil
        }
        let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
        let object = try JSONDecoder().decode(T.self, from: jsonData)
        return object
    }
}
