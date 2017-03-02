/**
 * History
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit

class History: NSObject {

    var user : User?;
    
    var message : Message?;
    
    init(user : User, message : Message) {
        self.user = user;
        self.message = message;
    }
    
}
