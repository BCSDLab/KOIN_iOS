//
//  CoreDataService.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/24/24.
//

import CoreData
import Foundation

class CoreDataService {
    static let shared = CoreDataService()
    
    private init() { }
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as? NSError {
                debugPrint("Unresolved Error \(error.description)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func insert<T: NSManagedObject>(insertedObject: T) {
        context.insert(insertedObject)
        saveContext()
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            }
            catch {
                let error = error as NSError
                debugPrint("Unresolved error \(error)")
            }
        }
    }
    
    func fetchEntities<T: NSManagedObject>(objectType: T.Type, predicate: NSPredicate? = nil) -> [T]? {
        let entityName = String(describing: objectType)
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
       
        do {
            return try context.fetch(fetchRequest)
        }
        catch {
            debugPrint("Fetch CoreData Process Failed")
            return nil
        }
    }
    
    func delete<T: NSManagedObject>(deletedObject: T) {
        context.delete(deletedObject)
        saveContext()
    }
}
