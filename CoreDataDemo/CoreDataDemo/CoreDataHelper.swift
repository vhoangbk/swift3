//
//  CoreDataHelper.swift
//  CoreDataDemo
//
//  Created by Hoang Nguyen on 2/25/17.
//  Copyright © 2017 Hoang Nguyen. All rights reserved.
//

import UIKit
import CoreData

class CoreDataHelper: NSObject {
	
	/*
	 * get all row entity
	 */
	func getAll(entityName : String) -> [NSManagedObject]{
		let appdelegate = UIApplication.shared.delegate as! AppDelegate;
		let context = appdelegate.persistentContainer.viewContext;
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName);
		request.returnsObjectsAsFaults = false;
		do{
			let results = try context.fetch(request) as! [NSManagedObject];
			return results;
		}catch{
			
		}
		
		return [NSManagedObject]();
	}
	
	/*
	 * id format : x-coredata://73494A28-416A-449B-A635-99134E6A7B88/Users/p3
	 * get : result.objectID.uriRepresentation().absoluteString
	 */
	func getById(id : String) -> NSManagedObject {
		let appdelegate = UIApplication.shared.delegate as! AppDelegate;
		let context = appdelegate.persistentContainer.viewContext;
		let objectID = context.persistentStoreCoordinator!.managedObjectID(forURIRepresentation: URL.init(string: id)!);
		
		let result = context.object(with: objectID!);
		return result;
	}
	
	/*
	 * get by request
	 * predicate = NSPredicate(format: "username == %@", "hung");
	 */
	func query(entityName : String, predicate : NSPredicate) -> [NSManagedObject] {
		let appdelegate = UIApplication.shared.delegate as! AppDelegate;
		let context = appdelegate.persistentContainer.viewContext;
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName);
		request.returnsObjectsAsFaults = false;
		
		request.predicate = predicate;
		
		do{
			let results = try context.fetch(request) as! [NSManagedObject];
			return results;
			
		}catch{
			
		}
		
		return [NSManagedObject]();
	}
}
