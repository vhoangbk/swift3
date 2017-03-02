/*
 * ResponeRemove.swift
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import ObjectMapper

class ResponeRemove: Mappable {
    
    static let TopicIsDeleted = 15002;
    
    /*
     TopicIsDeleted: 15002,
     UserIsDeleted: 15001,
     YouAreDeleted: 15000,
     LoginAgain: 1000
     
    {success: false, error_code: 1001, error: "TOPIC_NOT_FOUND"}
     */

    var success: Bool?
    var errorCode: Int?
    var error: String?
    var like: Int?
    
    var user : User?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        success    <- map["success"]
        errorCode  <- map["error_code"]
        error    <- map["error"]
    }
}
