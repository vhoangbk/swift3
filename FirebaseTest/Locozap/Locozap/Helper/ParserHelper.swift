/**
 * ParserHelper
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import SwiftyJSON
import ObjectMapper

class ParserHelper: NSObject {

    func parserUser(data : JSON) -> User {
        
        return User(JSONString: data.rawString()!)!;
    }
    
    func parserMessage(data : JSON) -> Message {
        
        return Message(JSONString: data.rawString()!)!;
    }
    
    func parserTopic(data : JSON) -> Topic {
        
        return Topic(JSONString: data.rawString()!)!;
    }
    
    func parserUserAround(data : JSON) -> ObjectAroundLocationCurrent {
        
        return ObjectAroundLocationCurrent(JSONString: data.rawString()!)!;
    }
    
    func pareserModel<T : Mappable>(data : JSON) -> T {
        return T(JSONString: data.rawString()!)!;
    }
    
    
    func parserResponseLikeMessage(data : JSON) -> ResponseLikeMessage {
        return ResponseLikeMessage(JSONString: data.rawString()!)!;
    }
    
    func parserHistoryChat(data : JSON) -> HistoryChat {
        return HistoryChat(JSONString: data.rawString()!)!;
    }
    
    func parserMessageChat(data : JSON) -> MessageChat {
        return MessageChat(JSONString: data.rawString()!)!;
    }
    
    func parserUploadImage(data : JSON) -> ResponseUploadImage? {
       return ResponseUploadImage(JSONString: data.rawString()!);
    }
    
    func parserBlock(data : JSON) -> Block? {
        return Block(JSONString: data.rawString()!);
    }
    
    func parserResponseRemove(data : JSON) -> ResponeRemove? {
        return ResponeRemove(JSONString: data.rawString()!);
    }
    
}
