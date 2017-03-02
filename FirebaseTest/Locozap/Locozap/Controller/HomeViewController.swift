/**
 * HomeViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import SwiftyJSON
import GoogleMobileAds

class HomeViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var bannerAdMob: UIView!
    @IBOutlet weak var mTblPost: UITableView!
    @IBOutlet weak var mLblNoPost: UILabel!
    private var adg: ADGManagerViewController?
    var arrayPost = [ItemHome!] ();
    var mRefreshControl: UIRefreshControl!
    
    let totalItemOfSection: Int = 5;
    
    var viewAdg : UIView!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView();
        initTableView();
        initViewAdsAdg();
        callApiGetTopic(refreshData: false, completeReloadData: {
            
        });
    }
    
    func initView() {
        // Init refresh view control
        mRefreshControl = UIRefreshControl();
        //        mRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh");
        mRefreshControl.addTarget(self, action: #selector(HomeViewController.refreshTableView), for: UIControlEvents.valueChanged);
        mTblPost.addSubview(mRefreshControl);
        self.mLblNoPost.text = StringUtilities.getLocalizedString("nodata_all_post", comment: "");
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.reloadsViewWhenCreateTopic), name: Const.KEY_NOTIFICATION_RELOADS_TOP_WHEN_CREATE_TOPIC, object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.reloadsViewWhenCreateTopic), name: Const.KEY_NOTIFICATION_RELOADS_TOP_WHEN_ACTIVE_ACCOUNT_PREMIUM, object: nil);
    }
    
    func initViewAdsAdg(){
        let width = UIScreen.main.bounds.width;
        self.viewAdg = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 100));
        let params: [String : Any] = [
            "locationid": Const.LOCATION_ID_ADG,  // locationid：広告枠ID
            "adtype": String(ADGAdType.Large.rawValue),            // adtype：広告サイズ　0:320x50, 1:320x100, 2:300x250, 3:728x90
            "originx": width/2 - 160,           // originx：x座標
            "originy": 0           // originy：y座標
        ];
        adg = ADGManagerViewController(adParams: params, adView: self.viewAdg);
//        adg?.delegate = self.viewAdg;
        adg?.setFillerRetry(false);
        adg?.loadRequest();
    }
    
    func reloadsViewWhenCreateTopic(){
        self.arrayPost.removeAll();
        self.mTblPost.reloadData();
        callApiGetTopic(refreshData: false, completeReloadData: {
            self.mRefreshControl.endRefreshing();
        });
    }
    
    // MARK : Refresh view
    func refreshTableView(sender:AnyObject) {
        reloadsViewWhenCreateTopic();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Add view banner AdMob
        self.setAdMob(viewAdMob: bannerAdMob);
    }
    
    // MARK: -- Init view
    func initTableView(){
        // Init data soruce anh delegate
        self.mTblPost.dataSource = self;
        self.mTblPost.delegate = self;
        
        // Register cell
        let nibCell1 = UINib(nibName: "CellHomeFragment", bundle: nil);
        self.mTblPost.register(nibCell1, forCellReuseIdentifier: "mCell");
        
        let nibCell2 = UINib(nibName: "CellHomeFragmentADG", bundle: nil);
        self.mTblPost.register(nibCell2, forCellReuseIdentifier: "mCellADG");
        
    }
    @IBAction func pressHistory(_ sender: Any) {
        if (mUser == nil){
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("you_can_set_it_by_registering_an_account", comment: ""), titleButtonClose: StringUtilities.getLocalizedString("cancel", comment: ""), titleButtonOk: StringUtilities.getLocalizedString("btn_register", comment: ""), viewController: self, actionOK: { (alert : UIAlertAction) in
                
                let loginVC = LoginViewController();
                self.navigationController?.pushViewController(loginVC, animated: true);
                
            })
            return;
        }
        let historyVC = HistoryViewController();
        self.navigationController?.pushViewController(historyVC, animated: true);
    }
    
    // MARK: -- Table view delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayPost.count;
    }
    
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(!self.isUserPremium() && indexPath.row < self.arrayPost.count) {
            let itemHome = self.arrayPost[indexPath.row];
            if (itemHome == nil) {
                return 100;
            }
        }
        return 131;
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row < self.arrayPost.count) {
            let itemHome = self.arrayPost[indexPath.row];
            if (itemHome == nil) {
                let mCell = self.mTblPost.dequeueReusableCell(withIdentifier: "mCellADG") as! CellHomeFragmentADG;
                mCell.selectionStyle = UITableViewCellSelectionStyle.none;
                if(mCell.subviews.count > 0) {
                    for viewItem in mCell.subviews {
                        if(viewItem.isKind(of: ADGManagerViewController.self)) {
                            viewItem.removeFromSuperview();
                        }
                    }
                }
                mCell.addSubview(self.viewAdg);
                // Loads more item
                if ((self.arrayPost.count - 1) == indexPath.row && self.arrayPost.count >= Const.VALUE_PARAMS_LIMIT) {
                    callApiGetTopic(refreshData: true, completeReloadData: {
                        
                    })
                }
                return mCell;
            } else {
                let mCell = self.mTblPost.dequeueReusableCell(withIdentifier: "mCell") as! CellHomeFragment;
                mCell.selectionStyle = UITableViewCellSelectionStyle.none;
                let topic = itemHome!.topic;
                let user = itemHome!.user;
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
                mCell.cellDateTime.text = DateTimeUtils.getDateTabHomeAndHistory(second: topic.limitTime!);
                mCell.contraintWidthDateTime.constant = mCell.cellDateTime.intrinsicContentSize.width;
                mCell.cellFlagUser.image = Utils.getFlagCountry(code: user.codeCountry!);
                // Loads more item
                if ((self.arrayPost.count - 1) == indexPath.row && self.arrayPost.count >= Const.VALUE_PARAMS_LIMIT) {
                    callApiGetTopic(refreshData: true, completeReloadData: {
                        
                    })
                }
                return mCell;
            }
        }
        
        let mCellNull = self.mTblPost.dequeueReusableCell(withIdentifier: "mCellADG") as! CellHomeFragmentADG;
        mCellNull.selectionStyle = UITableViewCellSelectionStyle.none;
        return mCellNull;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(self.arrayPost.count > indexPath.row) {
            let itemHome = self.arrayPost[indexPath.row];
            if (itemHome != nil) {
                let chatVC = ChatGroupViewController();
                chatVC.itemHome = itemHome;
                self.navigationController?.pushViewController(chatVC, animated: true);
            }
        }
    }
    
    func callApiGetTopic(refreshData : Bool, completeReloadData : @escaping () -> Void){
        var isShowProgress = true;
        if (refreshData == false) {
            self.arrayPost.removeAll();
            isShowProgress = true;
        }else{
            isShowProgress = false;
        }
        
        var params : Dictionary = Dictionary<String, String>();
        if (mUser != nil) {
            params.updateValue((mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
        }
        let total = !self.isUserPremium() ? self.getTotalReal(total: self.arrayPost.count) : self.arrayPost.count;
        params.updateValue(String(total), forKey: Const.KEY_PARAMS_OFFSET);
        params.updateValue(String(Const.VALUE_PARAMS_LIMIT), forKey: Const.KEY_PARAMS_LIMIT);
        
        APIClient.sharedInstance.postRequest(Url: URL_TOPICS, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: isShowProgress, ShowAlert: true, Success: { (success : AnyObject) in
            let responseJson = JSON(success);
            let listTopic = responseJson["data"].arrayValue;
            let paserHelper : ParserHelper = ParserHelper();
            var countTopic : Int = 0;
            for itemTopic in listTopic {
                let user = paserHelper.parserUser(data: itemTopic["user"]);
                let topic = paserHelper.parserTopic(data: itemTopic["topic"]);
                let itemHome = ItemHome.init(user: user, topic: topic);
                if(self.isExitsInArrayPost(itemHomeInput: itemHome) == false) {
                    if (!self.isUserPremium()) {
                        let total = self.getTotalReal(total: self.arrayPost.count);
                        
                        if (total > 0 && total % 5 == 0) {
                            self.arrayPost.append(nil);
                            self.arrayPost.append(itemHome);
                        } else {
                            self.arrayPost.append(itemHome);
                        }
                    } else {
                        self.arrayPost.append(itemHome);
                    }
                    countTopic = countTopic + 1;
                }
            }
            if(countTopic > 0) {
                self.mTblPost.reloadData();
            }
            self.isShowNodata();
            completeReloadData();
        }) { (error : AnyObject?) in
            self.isShowNodata();
            completeReloadData();
        }
    }
    
    private func getTotalReal(total: Int) -> Int {
        let total_I = self.arrayPost.count * self.totalItemOfSection / (self.totalItemOfSection + 1);
        let total = (self.arrayPost.count - total_I == total_I / self.totalItemOfSection) ? total_I : total_I + 1;
        
        return total;
    }
    
    func isExitsInArrayPost(itemHomeInput : ItemHome) -> Bool {
        if (self.arrayPost.count > 0) {
            let totalLoop: Int = self.arrayPost.count - 1
            for i in 0...totalLoop {
                let item = self.arrayPost[i]
                if (item != nil && itemHomeInput.topic.id == item?.topic.id) {
                    return true;
                }
            }
        }
        return false;
    }
    
    func isShowNodata(){
        if(self.arrayPost.count > 0){
            self.mLblNoPost.isHidden = true;
        } else {
            self.mLblNoPost.isHidden = false;
            self.mTblPost.reloadData();
        }
    }
    
    //MARK: viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Please resume rotation at the screen display timing
        adg?.resumeRefresh()
    }
    
    deinit {
        adg?.delegate = nil;
        adg = nil;
    }
}

//MARK: listener ads adg
extension UIView: ADGManagerViewControllerDelegate {
    
    public func adgManagerViewControllerReceiveAd(_ adgManagerViewController: ADGManagerViewController!) {
        print("Received an ad.")
    }
    
    public func adgManagerViewControllerFailed(toReceiveAd adgManagerViewController: ADGManagerViewController!, code: kADGErrorCode) {
        print("Failed to receive an ad.(\(code.rawValue))")
        
        // ネットワーク不通/エラー多発/広告レスポンスなし 以外はリトライしてください
        switch code {
        case .adgErrorCodeNeedConnection, .adgErrorCodeExceedLimit, .adgErrorCodeNoAd:
            break
        default:
            adgManagerViewController.loadRequest()
        }
    }
    
}
