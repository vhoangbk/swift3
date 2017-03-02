/**
 * SystemSetInfoBadgeTabbar
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import Foundation

class SystemSetInfoBadgeTabbar: ISetInfoBadgeTabbar {
    public var type: TypeSetInfoBadgeTabbar;
    
    init() {
        self.type = TypeSetInfoBadgeTabbar.Increment;
    }
    
    init(isWelcome: Bool) {
        if (isWelcome) {
            self.type = TypeSetInfoBadgeTabbar.Welcome;
        } else {
            self.type = TypeSetInfoBadgeTabbar.Increment;
        }
    }
    
    public func setViewController(view: UIViewController) {
        
    }
    
    public func getValue() -> Int {
        return 1;
    }
    
    public func getData() -> Any? {
        return nil;
    }
}
