//
//  PostsActivityViewController.swift
//  Locozap
//
//  Created by MAC on 11/3/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import UIKit

class PostsActivityViewController: BaseViewController {
    @IBOutlet weak var btnToolBarLeft: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnToolBarRight: UIButton!
    @IBOutlet weak var btnTab1: UIButton!
    @IBOutlet weak var btnTab2: UIButton!
    @IBOutlet weak var btnTab3: UIButton!
    @IBOutlet weak var btnTab4: UIButton!
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        initView();
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true);
    }
    
    // MARK: Init view
    func initView(){
        self.btnToolBarLeft.setTitle(NSLocalizedString("activity_post_menu_left", comment: ""), for: UIControlState.normal);
        self.lblTitle.text = NSLocalizedString("activity_post_menu_center", comment: "");
        self.btnToolBarRight.setTitle(NSLocalizedString("activity_post_menu_right", comment: ""), for: UIControlState.normal);
        self.btnTab1.setTitle(NSLocalizedString("activity_post_during_loading", comment: ""), for: UIControlState.normal);
        self.btnTab2.setTitle(NSLocalizedString("activity_post_today", comment: ""), for: UIControlState.normal);
        self.btnTab3.setTitle(NSLocalizedString("activity_post_tomorrow", comment: ""), for: UIControlState.normal);
        self.btnTab4.setTitle(NSLocalizedString("activity_post_date_specified", comment: ""), for: UIControlState.normal);
        self.lbl1.text = NSLocalizedString("activity_post_enter_title", comment: "");
        self.lbl2.text = NSLocalizedString("activity_post_contents", comment: "");
    }
}
