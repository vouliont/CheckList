//
//  TaskStorage.swift
//  CheckList
//
//  Created by Владислав on 22.01.2021.
//

import Foundation
import CoreData

class TaskStorage {
    
    private let dataStack: DataStack
    
    init(dataStack: DataStack) {
        self.dataStack = dataStack
    }
    
    func loadAll() -> [Task] {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        let tasks = (try? dataStack.mainContext.fetch(fetchRequest)) ?? []
        return tasks
    }
    
    func refreshDB(with tasks: [Task]) {
        dataStack.performBackground { context in
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            if let tasksToBeDeleted = try? context.fetch(fetchRequest) {
                for task in tasksToBeDeleted {
                    context.delete(task)
                }
            }
            for task in tasks {
                context.insert(task)
            }
            do {
                try context.save()
                NotificationCenter.default.post(name: .TaskListDidChangeNotification, object: nil)
            } catch {
                context.reset()
                print(error.localizedDescription)
            }
        }
    }
    
}
