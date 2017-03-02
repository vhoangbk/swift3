/**
 * HistoryViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import SwiftyJSON

class HistoryViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var mTblPost: UITableView!
    @IBOutlet weak var mLblNoPost: UILabel!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    
    var arrayPost = [ItemHome] ();
    var mRefreshControl : UIRefreshControl!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView();
        initTableView();
        callApiGetOldTopic(isLoadsMore: false, completeReloadData: {
            
        })
    }
    
    func initView() {
        // Init refresh view control
        mRefreshControl = UIRefreshControl();
        //        mRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh");
        mRefreshControl.addTarget(self, action: #selector(HomeViewController.refreshTableView), for: UIControlEvents.valueChanged);
        mTblPost.addSubview(mRefreshControl);
        self.mLblNoPost.text = StringUtilities.getLocalizedString("nodata_old_post", comment: "");
        self.mLblNoPost.isHidden = true;
        self.lblHeader.text =  StringUtilities.getLocalizedString("title_topic_old", comment: "");
        self.btnBack.setTitle(StringUtilities.getLocalizedString("cancel", comment: ""), for: UIControlState.normal);
    }
    
    // MARK : Refresh view
    func refreshTableView(sender:AnyObject) {
        self.arrayPost.removeAll();
        callApiGetOldTopic(isLoadsMore: false, completeReloadData: {
            self.mRefreshControl.endRefreshing();
        });
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }

    // MARK: -- Onclick view
    @IBAction func pressBack(_ sender: Any) {
        self.navigationController!.popViewController(animated: true);
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
        return 131;
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mCell = self.mTblPost.dequeueReusableCell(withIdentifier: "mCell") as! CellHomeFragment;
        mCell.selectionStyle = UITableViewCellSelectionStyle.none;
        if(indexPath.row < self.arrayPost.count) {
            let itemHome = self.arrayPost[indexPath.row];
            let topic = itemHome.topic;
            let user = itemHome.user;
            mCell.cellTitle.text = topic.title;
            mCell.cellTitle.textColor = Utils.getColorFromTypeTopic(typeCategory: Int(topic.category!));
            mCell.cellContent.text = topic.content;
            mCell.cellNumberMessage.text = String((topic.messageCount)!);
            if (Utils.getFullName(user: user).characters.count > Const.MAX_LENGTH_FULL_NAME) {
                mCell.cellUserName.text = Utils.getFullName(user: user).substring(to: Const.MAX_LENGTH_FULL_NAME) + "...";
            } else {
                mCell.cellUserName.text = Utils.getFullName(user: user);
            }
            if(user.avatarSmall != nil){
                mCell.cellAvatarUser.sd_setImage(with: URL(string: user.avatarSmall!), placeholderImage: UIImage(named: "avatar_no_image"));
            } else {
                mCell.cellAvatarUser.image = UIImage(named: "avatar_no_image");
            }
            
            mCell.cellIcon.image = Utils.getTopicFormType(typeTopic: topic.category!);
            mCell.cellDateTime.text =  DateTimeUtils.getDateTabHomeAndHistory(second: topic.limitTime!);
            mCell.contraintWidthDateTime.constant = mCell.cellDateTime.intrinsicContentSize.width;
            mCell.cellFlagUser.image = Utils.getFlagCountry(code: user.codeCountry!);
            
            // Loads more item
            if ((self.arrayPost.count - 1) == indexPath.row && self.arrayPost.count >= Const.VALUE_PARAMS_LIMIT) {
                callApiGetOldTopic(isLoadsMore: true, completeReloadData: {
                    
                });
            }
            
        }
        return mCell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(self.arrayPost.count > indexPath.row) {
            let chatVC = ChatGroupViewController();
            chatVC.itemHome = self.arrayPost[indexPath.row];
            chatVC.isLastPost = true;
            self.navigationController?.pushViewController(chatVC, animated: true);
        }
    }

    func callApiGetOldTopic(isLoadsMore : Bool, completeReloadData : @escaping () -> Void){
        var isShowProgress = true;
        if (isLoadsMore == false) {
            self.arrayPost.removeAll();
            isShowProgress = true;
        }else{
            isShowProgress = false;
        }
        
        var params : Dictionary = Dictionary<String, String>();
        if (mUser != nil) {
            params.updateValue((mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
        }
        params.updateValue(String(self.arrayPost.count), forKey: Const.KEY_PARAMS_OFFSET);
        params.updateValue(String(Const.VALUE_PARAMS_LIMIT), forKey: Const.KEY_PARAMS_LIMIT);
        APIClient.sharedInstance.postRequest(Url: URL_OLD_TOPICS, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: isShowProgress, ShowAlert: true, Success: { (success : AnyObject) in
            let responseJson = JSON(success);
            let listTopic = responseJson["data"].arrayValue;
            let paserHelper : ParserHelper = ParserHelper();
            var countTopic : Int = 0;
            for itemTopic in listTopic{
                let user = paserHelper.parserUser(data: itemTopic["user"]);
                let topic = paserHelper.parserTopic(data: itemTopic["topic"]);
                let itemHome = ItemHome.init(user: user, topic: topic);
                if(self.isExitsInArrayPost(itemHomeInput: itemHome) == false){
                    self.arrayPost.append(itemHome);
                    countTopic = countTopic + 1;
                }
            }
            if(countTopic > 0) {
                self.mTblPost.reloadData();
            }
            self.isShowNodata();
            completeReloadData();
        }) { (error : AnyObject?) in
            completeReloadData();
            self.isShowNodata();
        }
    }
    
    func isShowNodata(){
        if(self.arrayPost.count > 0){
            self.mLblNoPost.isHidden = true;
        } else {
            self.mLblNoPost.isHidden = false;
            self.mTblPost.reloadData();
        }
    }
    
    func isExitsInArrayPost(itemHomeInput : ItemHome) -> Bool{
        for item in self.arrayPost {
            if(itemHomeInput.topic.id == item.topic.id){
                return true;
            }
        }
        return false;
    }

}
