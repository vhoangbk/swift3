/**
 * ItemHome
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */


import Foundation
class ItemHome: NSObject {
    var user : User;
    var topic : Topic;
    
    init(user : User, topic : Topic) {
        self.user = user;
        self.topic = topic;
    }
}
