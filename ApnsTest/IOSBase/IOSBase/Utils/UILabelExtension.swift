//
//  UILabelExtension.swift
//  IOSBase
//
//  Created by paraline on 2/22/17.
//  Copyright © 2017 paraline. All rights reserved.
//

import Foundation
import UIKit

extension UILabel{
    
    func wrapContent() -> CGRect{
        let fixedWidth = self.frame.size.width
        self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = self.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        self.frame = newFrame;
        return newFrame;
    }
}
