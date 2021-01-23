//
//  FirebaseDatabase.swift
//  CheckList
//
//  Created by Владислав on 21.01.2021.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class FirebaseStorage {
    static let shared = FirebaseStorage()
    
    private var db: DatabaseReference!
    private var tasksHandle: UInt?
    
    private init() {}
    
    func initialize() {
        db = Database.database().reference()
    }
    
    func createTask(named name: String,
                    description: String? = nil,
                    date: Date? = nil,
                    completionHandler: ((_ taskId: String, _ finished: Bool) -> Void)? = nil) {
        guard let userUid = Auth.auth().currentUser?.uid,
              let taskId = db.child("users/\(userUid)/tasks").childByAutoId().key else {
            return
        }
        var task: [String: Any] = [
            "name": name,
            "completed": false
        ]
        if let description = description {
            task["taskDescription"] = description
        }
        if let date = date {
            task["date"] = date.timeIntervalSince1970
        }
        db.updateChildValues(
            ["users/\(userUid)/tasks/\(taskId)": task]
        ) { error, dbRef in
            completionHandler?(taskId, error == nil)
        }
    }
    
    func updateTask(with taskId: String,
                    name: String? = nil,
                    description: String? = nil,
                    completed: Bool? = nil,
                    date: Date? = nil,
                    completionHandler: ((_ finished: Bool) -> Void)? = nil) {
        guard let userUid = Auth.auth().currentUser?.uid else {
            return
        }
        var taskValueChanges: [String: Any] = [:]
        let taskRef = "users/\(userUid)/tasks/\(taskId)"
        if let name = name {
            taskValueChanges["\(taskRef)/name"] = name
        }
        if let description = description {
            taskValueChanges["\(taskRef)/taskDescription"] = description
        }
        if let completed = completed {
            taskValueChanges["\(taskRef)/completed"] = completed
        }
        if let date = date {
            taskValueChanges["\(taskRef)/date"] = date.timeIntervalSince1970
        }
        db.updateChildValues(taskValueChanges) { error, dbRef in
            completionHandler?(error == nil)
        }
    }
    
    func deleteTask(with taskId: String) {
        guard let userUid = Auth.auth().currentUser?.uid else {
            return
        }
        db.child("users").child(userUid).child("tasks").child(taskId).removeValue()
    }
}
