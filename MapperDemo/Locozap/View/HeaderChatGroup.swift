//
//  HeaderChatGroup.swift
//  Locozap
//
//  Created by paraline on 11/3/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import UIKit

class HeaderChatGroup: UIView {

    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var contraintHeightContent: NSLayoutConstraint!
    
    var isExpand : Bool = true;
    var isAnimation : Bool = false;
    
    let duration = 0.5;
    
    class func sharedInstance() -> HeaderChatGroup{
        let headerChatGroup = Bundle.main.loadNibNamed("HeaderChatGroup", owner: self, options: nil)?.last as! HeaderChatGroup;
        headerChatGroup.initView();
        return headerChatGroup;
    }

    
    // MARK: Init view
    private func initView() {
        
    }
    
    @IBAction func pressExpandOrCollapse(_ sender: AnyObject) {
        if (isExpand == true){
            self.collapse();
        }else{
            expand();
        }
    }
    
    func collapse() {
        if (self.isAnimation == true){
            return;
        }
        self.isAnimation = true;
        UIView.animate(withDuration: duration, animations: {
            self.viewContent.frame.origin.y = -269;
        }) { (completed : Bool) in
            self.isExpand = false;
            self.isAnimation = false;
        }
    }
    
    func expand() {
        if (self.isAnimation == true){
            return;
        }
        self.isAnimation = true;
        UIView.animate(withDuration: duration, animations: {
            self.viewContent.frame.origin.y = 35;
        }) { (completed : Bool) in
            self.isExpand = true;
            self.isAnimation = false;
        }
    }
}
