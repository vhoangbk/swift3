//
//  HomeViewController.swift
//  Locozap
//
//  Created by Hoang Nguyen on 10/11/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import UIKit
import SwiftyJSON

class HomeViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var mBtnAllPost: UIButton!
    @IBOutlet weak var mBtnPostYourReply: UIButton!
    @IBOutlet weak var mTblPost: UITableView!
    var arrayPost = [ItemHome] ();
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView();
        
        initTableView();
        callApiGetTopic();
    }
    
    func initView() {
        self.mBtnAllPost.setTitle(NSLocalizedString("all_posts", comment: ""), for: UIControlState.normal);
        self.mBtnPostYourReply.setTitle(NSLocalizedString("reply_posts", comment: ""), for: UIControlState.normal);
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }

    @IBAction func pressHome(_ sender: AnyObject) {
        let chatVC = ChatGroupViewController();
        self.navigationController?.pushViewController(chatVC, animated: true);
    }
	
    // MARK: -- action click bottom tab
    @IBAction func pressActionAllPost(_ sender: AnyObject) {
        onClickTabButton(isCheckAllPost: true);
    }
    @IBAction func pressActionPostYouReply(_ sender: AnyObject) {
        onClickTabButton(isCheckAllPost: false);
    }
    
    func onClickTabButton(isCheckAllPost : Bool) {
        if (isCheckAllPost) {
            self.mBtnAllPost.setBackgroundImage(UIImage(named: "bg_btn_rounded_rectangle_home"), for: UIControlState.normal);
            self.mBtnPostYourReply.setBackgroundImage(nil, for: UIControlState.normal);
        } else {
            self.mBtnAllPost.setBackgroundImage(nil, for: UIControlState.normal);
            self.mBtnPostYourReply.setBackgroundImage(UIImage(named: "bg_btn_rounded_rectangle_home"), for: UIControlState.normal);
        }
    }

    // MARK: -- Init view
    func initTableView(){
        // Init data soruce anh delegate
        self.mTblPost.dataSource = self;
        self.mTblPost.delegate = self;
        
        // Register cell
        let nibCell1 = UINib(nibName: "CellHomeFragment", bundle: nil);
        self.mTblPost.register(nibCell1, forCellReuseIdentifier: "mCell");
    }

    // MARK: -- Table view delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayPost.count;
    }
    
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105;
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mCell = self.mTblPost.dequeueReusableCell(withIdentifier: "mCell") as! CellHomeFragment;
        mCell.selectionStyle = UITableViewCellSelectionStyle.none;
        let itemHome = self.arrayPost[indexPath.row];
        let topic = itemHome.topic;
        let user = itemHome.user;
        mCell.cellTitle.text = topic.title;
        mCell.cellContent.text = topic.content;
        mCell.cellNumberMessage.text = String(topic.messageCount);
        mCell.cellUserName.text = user.fistName! + user.lastName!;
        mCell.cellAvatarUser.sd_setImage(with: URL(string: user.avatar!), placeholderImage: UIImage(named: "avatar_no_image"));
        mCell.cellIcon.sd_setImage(with: URL(string: topic.icon), placeholderImage: UIImage(named: "avatar_no_image"));
        return mCell;
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVC = ChatGroupViewController();
        chatVC.itemHome = self.arrayPost[indexPath.row];
        self.navigationController?.pushViewController(chatVC, animated: true);
    }

    func callApiGetTopic(){
        var params : Dictionary = Dictionary<String, String>();
        if (mUser == nil) {
            return;
        }
        params.updateValue((mUser?.token)!, forKey: Const.KEY_PARAMS_TOKEN);
        APIClient.sharedInstance.postRequest(Url: URL_TOPICS, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: true, ShowAlert: true, Success: { (success : AnyObject) in
            let responseJson = JSON(success);
            let listTopic = responseJson["data"].arrayValue;
            let paserHelper : ParserHelper = ParserHelper();
            for itemTopic in listTopic{
                let user = paserHelper.parserUser(data: itemTopic["user"]);
                let topic = paserHelper.parserTopic(data: itemTopic["topic"]);
                let itemHome = ItemHome.init(user: user, topic: topic);
                self.arrayPost.append(itemHome);
                self.mTblPost.reloadData();
            }
            
        }) { (error : AnyObject?) in
            
        }
    }
}
