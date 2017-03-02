/**
 * NotificationSetInfoBadgeTabbar
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import Foundation

class NotificationSetInfoBadgeTabbar: ISetInfoBadgeTabbar {
    public var type: TypeSetInfoBadgeTabbar;
    private var data: ObjectMessage?;
    private var viewController: NotificationViewController?;
    private var badge: Int;
    
    init(data: ObjectMessage?) {
        self.type = TypeSetInfoBadgeTabbar.Increment;
        self.data = data;
        self.viewController = nil;
        self.badge = 1;
    }
    
    init(badge: Int) {
        self.type = TypeSetInfoBadgeTabbar.Fix;
        self.data = nil;
        self.viewController = nil;
        self.badge = badge;
    }
    
    public func setViewController(view: UIViewController) {
        self.viewController = view as? NotificationViewController;
    }
    
    public func getValue() -> Int {
        return self.badge;
    }
    
    public func getData() -> Any? {
        return self.data;
    }
}
