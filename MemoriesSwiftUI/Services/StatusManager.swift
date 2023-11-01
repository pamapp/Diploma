//
//  StatusDataService.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 24.10.2023.
//

import Foundation
import CoreData

class StatusManager {
    static let shared = StatusManager()
    
    private init() { }
    
    func getStatusMO() -> StatusMO {
        let context = PersistenceController.shared.container.viewContext
        
        if let existingStatus = try? context.fetch(StatusMO.fetchRequest()).first {
            return existingStatus
        } else {
            let newStatus = StatusMO(context: context)
            newStatus.value = 0
            newStatus.isChanged = false
            try? context.save()
            return newStatus
        }
    }
    
    func updateValue(newValue: Int) {
        let status = self.getStatusMO()
        status.value = Int16(newValue)
        try? status.managedObjectContext?.save()
    }
    
    func updateIsChanged(newValue: Bool) {
        let status = self.getStatusMO()
        status.isChanged = newValue
        try? status.managedObjectContext?.save()
    }
}
