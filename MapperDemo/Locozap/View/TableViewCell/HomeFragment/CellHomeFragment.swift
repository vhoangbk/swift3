//
//  CellHomeFragment.swift
//  Locozap
//
//  Created by MAC on 10/13/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import UIKit

class CellHomeFragment: UITableViewCell {
    @IBOutlet weak var cellIcon: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellContent: UILabel!
    @IBOutlet weak var cellAvatarUser: UIImageView!
    @IBOutlet weak var cellFlagUser: UIImageView!
    @IBOutlet weak var cellUserName: UILabel!
    @IBOutlet weak var cellNumberMessage: UILabel!
    @IBOutlet weak var cellDateTime: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
