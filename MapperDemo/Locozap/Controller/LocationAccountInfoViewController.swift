//
//  LocationAccountInfoViewController.swift
//  Locozap
//
//  Created by MAC on 11/2/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import UIKit

class LocationAccountInfoViewController: BaseViewController {
    @IBOutlet weak var lbNameUser: UILabel!
    @IBOutlet weak var btnChat: UIButton!
    @IBOutlet weak var btnFriendRequest: UIButton!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var lbInfoAccount: UILabel!
    @IBOutlet weak var lbJapanese: UILabel!
    @IBOutlet weak var lbEnglish: UILabel!
    @IBOutlet weak var lbPortuguese: UILabel!
    @IBOutlet weak var lbNumberLikeUser: UILabel!
    @IBOutlet weak var lbTitleLeft: UILabel!
    @IBOutlet weak var lbTitleCenter: UILabel!
    @IBOutlet weak var avatarUser: UIImageView!
    
    var userAround : User = User.init();

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        self.navigationController?.setNavigationBarHidden(true, animated: true);
        
//        self.title = NSLocalizedString("title_center_tool_bar", comment: "");
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: Init view
    func initView() {
        
        self.lbNameUser.text = userAround.fistName! + userAround.lastName!;
        self.lbTitleLeft.text = NSLocalizedString("title_left_tool_bar", comment: "");
        self.lbTitleCenter.text = NSLocalizedString("title_center_tool_bar", comment: "");
        self.lbJapanese.text = NSLocalizedString("name_japan_location_account_info", comment: "");
        self.lbEnglish.text = NSLocalizedString("name_english_location_account_info", comment: "");
        self.lbPortuguese.text = NSLocalizedString("name_portuguese_location_account_info", comment: "");
        self.btnChat.setTitle(NSLocalizedString("button_chat", comment: ""), for: UIControlState.normal);
        self.btnFriendRequest.setTitle(NSLocalizedString("button_friend_request", comment: ""), for: UIControlState.normal);
        avatarUser.sd_setImage(with: URL(string: userAround.avatar!), placeholderImage: UIImage(named: "avatar_no_image"));
    }
    
    // MARK: OnClick view
    @IBAction func pressChat(_ sender: AnyObject) {
        let chatOneVC = ChatOneViewController();
        chatOneVC.userAround = self.userAround;
        self.navigationController?.pushViewController(chatOneVC, animated: true);
    }
    
    @IBAction func pressFriendRequest(_ sender: AnyObject) {
    }
   
    @IBAction func pressBack(_ sender: AnyObject) {
        didPressBack();
    }

}
