//
//  DBComunicationService.swift
//  CheckList
//
//  Created by Владислав on 22.01.2021.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import CoreData

final class DBCommunicationService {
    private let taskStorage: TaskStorage
    private let db = Database.database().reference()
    private var refHandle: UInt?
    var unManager: UNManager!
    
    init(dataStack: DataStack) {
        taskStorage = TaskStorage(dataStack: dataStack)
    }
    
    func start() {
        guard refHandle == nil,
              let userUid = Auth.auth().currentUser?.uid else {
            return
        }
        refHandle = db.child("users")
            .child(userUid)
            .child("tasks")
            .observe(.value, with: { [weak self] snapshot in
                guard let encodedTasks = snapshot.value as? [String: [String: Any]] else {
                    self?.taskStorage.refreshDB(with: [])
                    return
                }
                var tasks = [Task]()
                for (taskId, encodedTask) in encodedTasks {
                    guard let taskName = encodedTask["name"] as? String else {
                        break
                    }
                    let task = Task(entity: Task.entity(), insertInto: nil)
                    task.id = taskId
                    task.name = taskName
                    task.taskDescription = encodedTask["taskDescription"] as? String
                    task.completed = (encodedTask["completed"] as? Bool) ?? false
                    if let dateInterval = encodedTask["date"] as? TimeInterval {
                        task.date = Date(timeIntervalSince1970: dateInterval)
                    }
                    tasks.append(task)
                }
                self?.taskStorage.refreshDB(with: tasks)
                self?.unManager.cancelAllNotifications()
                self?.scheduleNotifications(for: tasks)
        })
    }
    
    func stop() {
        guard let refHandle = refHandle else {
            return
        }
        db.removeObserver(withHandle: refHandle)
        self.refHandle = nil
    }
    
    private func scheduleNotifications(for tasks: [Task]) {
        for task in tasks {
            guard let remindMeDate = task.date,
                  remindMeDate > Date() else {
                break
            }
            unManager.scheduleNotification(with: task.id!,
                                           title: task.name!,
                                           body: task.taskDescription ?? "",
                                           date: remindMeDate)
        }
    }
}
