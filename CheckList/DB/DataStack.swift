//
//  DataTask.swift
//  CheckList
//
//  Created by Владислав on 22.01.2021.
//

import Foundation
import CoreData

class DataStack {

    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CheckList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var mainContext = persistentContainer.viewContext
    
    func performBackground(_ handler: @escaping (_ context: NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(handler)
    }
    
    func saveContext () {
        if mainContext.hasChanges {
            do {
                try mainContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
