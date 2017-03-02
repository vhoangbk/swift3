//
//  StephencelisDB.swift
//  IOSBase
//
//  Created by paraline on 2/28/17.
//  Copyright © 2017 paraline. All rights reserved.
//
/*
 ContactEntity.instance.createTable();
 let id = ContactEntity.instance.addContact(cname: "contact 13", cphone: "1223", caddress: "ha noi 3")
 if (id == -1){
 print("fail")
 }else{
 print("success \(id)");
 }
 
 let contacts : [Contact] = ContactEntity.instance.getContacts();
 for contact in contacts {
 print(contact.name);
 }
 */

import UIKit
import SQLite

let DB_NAME : String = "db.sqlite3"

class ContactEntity: NSObject {
    
    static let instance = ContactEntity()
    private let db: Connection?
    
    private let contacts = Table("contacts")
    private let id = Expression<Int64>("id")
    private let name = Expression<String?>("name")
    private let phone = Expression<String>("phone")
    private let address = Expression<String>("address")
    
    private override init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        do {
            db = try Connection("\(path)/\(DB_NAME)")
        } catch {
            db = nil
            print ("Unable to open database")
        }
        
    }
    
    func createTable() {
        do {
            try db!.run(contacts.create(ifNotExists: true) { table in
                table.column(id, primaryKey: true)
                table.column(name)
                table.column(phone, unique: true)
                table.column(address)
            })
        } catch {
            print("Unable to create table")
        }
    }
    
    func addContact(cname: String, cphone: String, caddress: String) -> Int64? {
        do {
            let insert = contacts.insert(name <- cname, phone <- cphone, address <- caddress)
            print(insert.asSQL())
            let id = try db!.run(insert)
            
            return id
        } catch {
            print("Insert failed")
            return -1
        }
    }
    
    func getContacts() -> [Contact] {
        var contacts = [Contact]()
        
        do {
            for contact in try db!.prepare(self.contacts) {
                contacts.append(Contact(
                    id: contact[id],
                    name: contact[name]!,
                    phone: contact[phone],
                    address: contact[address]))
            }
        } catch {
            print("Select failed")
        }
        
        return contacts
    }
    
    func deleteContact(cid: Int64) -> Bool {
        do {
            let contact = contacts.filter(id == cid)
            try db!.run(contact.delete())
            return true
        } catch {
            print("Delete failed")
        }
        return false
    }
    
    func updateContact(cid:Int64, newContact: Contact) -> Bool {
        let contact = contacts.filter(id == cid)
        do {
            let update = contact.update([
                name <- newContact.name,
                phone <- newContact.phone,
                address <- newContact.address
                ])
            if try db!.run(update) > 0 {
                return true
            }
        } catch {
            print("Update failed: \(error)")
        }
        
        return false
    }

}
