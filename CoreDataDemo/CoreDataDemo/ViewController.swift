//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Hoang Nguyen on 2/25/17.
//  Copyright © 2017 Hoang Nguyen. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		let codataHelper = CoreDataHelper();
		let listUser : [NSManagedObject] = codataHelper.getAll(entityName: "Uses");
		if (listUser.count > 0){
			for result in listUser{
				if let username = result.value(forKey: "username") {
					print(username);
				}
				if let password = result.value(forKey: "password") {
					print(password);
				}
				
				let objId = result.objectID.uriRepresentation().absoluteString
				print(objId);
			}
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	
	@IBAction func pressSave(_ sender: AnyObject) {
		let appdelegate = UIApplication.shared.delegate as! AppDelegate;
		let context = appdelegate.persistentContainer.viewContext;
		let user = NSEntityDescription.insertNewObject(forEntityName: "Users", into: context)
		user.setValue("hung", forKey: "username");
		user.setValue("1234567", forKey: "password");
		
		do {
			try context.save();
		} catch {
			
		}
		
	}

	@IBAction func pressRead(_ sender: AnyObject) {
		let appdelegate = UIApplication.shared.delegate as! AppDelegate;
		let context = appdelegate.persistentContainer.viewContext;
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users");
		request.returnsObjectsAsFaults = false;
		do{
			let results = try context.fetch(request) as! [NSManagedObject];
			if (results.count > 0){
				for result in results{
					if let username = result.value(forKey: "username") {
						print(username);
					}
					if let password = result.value(forKey: "password") {
						print(password);
					}
					
					let objId = result.objectID.uriRepresentation().absoluteString
					print(objId);
				}
			}
			
		}catch{
			
		}
	}
	
	@IBAction func pressReadById(_ sender: AnyObject) {
		self.readById(id: "x-coredata://73494A28-416A-449B-A635-99134E6A7B88/Users/p3")
	}
	
	func readById(id : String) {
		let appdelegate = UIApplication.shared.delegate as! AppDelegate;
		let context = appdelegate.persistentContainer.viewContext;
		let objectID = context.persistentStoreCoordinator!.managedObjectID(forURIRepresentation: URL.init(string: id)!);

		let result = context.object(with: objectID!);
		if let username = result.value(forKey: "username") {
			print(username);
		}
		if let password = result.value(forKey: "password") {
			print(password);
		}
			
		let objId = result.objectID.uriRepresentation().absoluteString
		print(objId);
		
	}
	
	func readBy()  {
		let appdelegate = UIApplication.shared.delegate as! AppDelegate;
		let context = appdelegate.persistentContainer.viewContext;
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users");
		request.returnsObjectsAsFaults = false;
		
		let predicate = NSPredicate(format: "username == %@", "hung");
		request.predicate = predicate;
		
		do{
			let results = try context.fetch(request) as! [NSManagedObject];
			if (results.count > 0){
				for result in results{
					if let username = result.value(forKey: "username") {
						print(username);
					}
					if let password = result.value(forKey: "password") {
						print(password);
					}
					
					let objId = result.objectID.uriRepresentation().absoluteString
					print(objId);
				}
			}
			
		}catch{
			
		}
	}
	@IBAction func pressReadBy(_ sender: AnyObject) {
		readBy();
	}
}

