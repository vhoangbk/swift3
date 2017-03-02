/**
 * NullSetInfoBadgeTabbar
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import Foundation

class NullSetInfoBadgeTabbar: ISetInfoBadgeTabbar {
    public var type: TypeSetInfoBadgeTabbar;
    
    init() {
        self.type = TypeSetInfoBadgeTabbar.Null;
    }
    
    public func setViewController(view: UIViewController) {
        
    }
    
    public func getValue() -> Int {
        return 0;
    }
    
    public func getData() -> Any? {
        return nil;
    }
}
