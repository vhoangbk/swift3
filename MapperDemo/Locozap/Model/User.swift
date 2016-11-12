//
//  User.swift
//  Locozap
//
//  Created by paraline on 10/13/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var id : String?;
    
    var fistName : String?;
    
    var lastName : String?;
    
    var email : String?;
    
    var country : String?;
    
    var avatar : String?;
    
    var birthday : String?;
    
    var token : String?;
    
    var latitude : String?;
    
    var longitude : String?;
    
    var isLike : Bool?;
    
    init(id : String, fistName : String, lastName : String, email : String, country : String, avatar : String, birthday : String, token : String, latitude : String, longitude : String) {
        
        self.id = id;
        self.fistName = fistName;
        self.lastName = lastName;
        self.email = email;
        self.country = country;
        self.avatar = avatar;
        self.birthday = birthday;
        self.token = token;
        self.latitude = latitude;
        self.longitude = longitude;
    }
    override init(){};
}
