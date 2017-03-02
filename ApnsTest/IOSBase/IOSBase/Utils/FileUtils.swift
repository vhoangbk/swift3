//
//  FileUtils.swift
//  IOSBase
//
//  Created by paraline on 2/28/17.
//  Copyright © 2017 paraline. All rights reserved.
//

import UIKit

class FileUtils: NSObject {

    class func getPathDocuments(fileName: String) -> String {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        return fileURL.path
    }
    
    class func copyFile(fileName: String) -> NSError? {
        let dbPath: String = getPathDocuments(fileName: fileName)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dbPath) {
            let documentsURL = Bundle.main.resourceURL
            let fromPath = documentsURL?.appendingPathComponent(fileName)
            var error : NSError?
            do {
                try fileManager.copyItem(atPath: fromPath!.path, toPath: dbPath)
            } catch let error1 as NSError {
                error = error1
            }
            return error;
        }
        
        return nil;
    }

}
