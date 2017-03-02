/**
 * NotificationViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import SwiftyJSON

class NotificationViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var viewNotification: UIView!
    @IBOutlet weak var viewMessage: UIView!
    @IBOutlet weak var mTblNotification: UITableView!
    @IBOutlet weak var mTblMessage: UITableView!
    @IBOutlet weak var segTab: UISegmentedControl!
    @IBOutlet weak var lblNoDataNotification: UILabel!
    @IBOutlet weak var lblNoDataMessage: UILabel!
    
    var mRefreshControlMessage: UIRefreshControl!
    var mRefreshControlNotification: UIRefreshControl!
    var arrayMessage = [ObjectMessage]();
    var arrayNotification = [ObjectNotification]();
    
    public var viewDidLoading = false;
    public static var visibleTabNotification = false;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.viewDidLoading = true;
        
        self.initView();
        initTableView();
        
        let indexSegment: Int = NotificationViewController.visibleTabNotification ? 1 : 0;
        showTabMessage(isShow: indexSegment == 0, indexSegment: indexSegment);
        NotificationViewController.visibleTabNotification = false;
        
        let widthSegmentItem = self.segTab.intrinsicContentSize.width / 2 + 20;
        self.segTab.setWidth(widthSegmentItem, forSegmentAt: 0);
        self.segTab.setWidth(widthSegmentItem, forSegmentAt: 1);
        
        self.lblNoDataNotification.isHidden = true;
        self.lblNoDataMessage.isHidden = true;
        if (self.viewNotification.isHidden) {
            
            callApiGetTopic(isRefresh: false, completeReloadData: {
                self.viewDidLoading = false;
            });
        } else {
            callApiGetPush(isRefresh: false, completeReloadData: {
                self.viewDidLoading = false;
            });
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(NotificationViewController.catchNotification), name: Const.KEY_NOTIFICATION_PUSH, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(NotificationViewController.catchMessage), name: Const.KEY_NOTIFICATION_MESSAGE, object: nil);
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
    
    func initView() {
        self.segTab.setTitle(StringUtilities.getLocalizedString("tab_message_fragment", comment: ""), forSegmentAt: 0);
        self.segTab.setTitle(StringUtilities.getLocalizedString("tab_notification_fragment", comment: ""), forSegmentAt: 1);
        self.lblNoDataMessage.text = StringUtilities.getLocalizedString("nodata_message_post", comment: "");
        self.lblNoDataNotification.text = StringUtilities.getLocalizedString("nodata_notify_post", comment: "");
        
        // Init refresh view control
        mRefreshControlMessage = UIRefreshControl();
        //        mRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh");
        mRefreshControlMessage.addTarget(self, action: #selector(NotificationViewController.refreshTableViewMessage), for: UIControlEvents.valueChanged);
        mTblMessage.addSubview(mRefreshControlMessage);
        
        mRefreshControlNotification = UIRefreshControl();
        mRefreshControlNotification.addTarget(self, action: #selector(NotificationViewController.refreshTableViewNotification), for: UIControlEvents.valueChanged);
        mTblNotification.addSubview(mRefreshControlNotification);
    }
    
    // MARK : Refresh view
    func refreshTableViewMessage(sender:AnyObject) {
        print("refreshTableViewMessage");
        callApiGetTopic(isRefresh: false, completeReloadData: {
            self.mRefreshControlMessage.endRefreshing();
        });
    }
    
    func refreshTableViewNotification(sender:AnyObject) {
        print("refreshTableViewNotification");
        callApiGetPush(isRefresh: false, completeReloadData: {
            self.mRefreshControlNotification.endRefreshing();
        });
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (!self.viewDidLoading) {
            self.arrayMessage.removeAll();
            self.arrayNotification.removeAll();
            
            if (self.viewMessage.isHidden) {
                callApiGetPush(isRefresh: false, completeReloadData: {
                    self.mRefreshControlNotification.endRefreshing();
                });
            } else {
                callApiGetTopic(isRefresh: false, completeReloadData: {
                    self.mRefreshControlMessage.endRefreshing();
                });
            }
        }
    }
    
    @IBAction func changeTab(_ sender: Any) {
        let segment: UISegmentedControl = sender as! UISegmentedControl;
        
        if (segment.selectedSegmentIndex == 0 && self.viewMessage.isHidden) {
            showTabMessage(isShow: true, indexSegment: nil);
            if (self.arrayMessage.isEmpty) {
                callApiGetTopic(isRefresh: false, completeReloadData: {
                    
                });
            }
        } else if (segment.selectedSegmentIndex == 1 && self.viewNotification.isHidden) {
            showTabMessage(isShow: false, indexSegment: nil);
            if (self.arrayNotification.isEmpty) {
                callApiGetPush(isRefresh: false, completeReloadData: {
                    
                });
            }
        }
    }
    
    private func showTabMessage(isShow: Bool, indexSegment: Int?) {
        self.viewMessage.isHidden = !isShow;
        self.viewNotification.isHidden = isShow;
        
        if (indexSegment != nil) {
            print("Set segment selected is " + String(describing: indexSegment));
            let index: Int = indexSegment!;
            self.segTab.selectedSegmentIndex = index;
        }
    }
    
    // MARK: -- Init view
    func initTableView(){
        // Init data soruce anh delegate
        self.mTblNotification.dataSource = self;
        self.mTblNotification.delegate = self;
        self.mTblMessage.dataSource = self;
        self.mTblMessage.delegate = self;
        
        // Register cell
        let nibCellNotification = UINib(nibName: "CellNotification", bundle: nil);
        let nibCellNotificationSystem = UINib(nibName: "CellNotificationSystem", bundle: nil);
        let nibCellMessage = UINib(nibName: "CellMessage", bundle: nil);
        
        self.mTblNotification.register(nibCellNotification, forCellReuseIdentifier: "mCellNotification");
        self.mTblNotification.register(nibCellNotificationSystem, forCellReuseIdentifier: "mCellNotificationSystem");
        self.mTblMessage.register(nibCellMessage, forCellReuseIdentifier: "mCellMessage");
    }
    @IBAction func pressHistory(_ sender: Any) {
        let historyVC = HistoryViewController();
        self.navigationController?.pushViewController(historyVC, animated: true);
    }
    
    // MARK: -- Table view delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == mTblNotification) {
            return self.arrayNotification.count;
        } else {
            return self.arrayMessage.count;
        }
    }
    
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65;
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == mTblNotification) {
            var mCell: UITableViewCell;
            if (self.arrayNotification.count > indexPath.row) {
                let itemNotification : ObjectNotification = self.arrayNotification[indexPath.row];
                if (itemNotification.type == TypeNotification.Welcome.rawValue) {
                    let cell = self.mTblNotification.dequeueReusableCell(withIdentifier: "mCellNotificationSystem") as! CellNotificationSystem;
                    mCell = createCellNotificationSystem(mCell: cell, itemNotification: itemNotification);
                } else {
                    let cell = self.mTblNotification.dequeueReusableCell(withIdentifier: "mCellNotification") as! CellNotification;
                    mCell = createCellNotification(mCell: cell, itemNotification: itemNotification);
                }
                
                // Loads more item
                if ((self.arrayNotification.count - 1) == indexPath.row && self.arrayNotification.count >= Const.VALUE_PARAMS_LIMIT) {
                    callApiGetPush(isRefresh: true, completeReloadData: {
                        
                    })
                }
            } else {
                mCell = self.mTblNotification.dequeueReusableCell(withIdentifier: "mCellNotificationSystem") as! CellNotificationSystem;
            }
            
            return mCell;
        } else {
            var mCell = self.mTblMessage.dequeueReusableCell(withIdentifier: "mCellMessage") as! CellMessage;
            if (self.arrayMessage.count > indexPath.row) {
                mCell = createCellMessage(mCell: mCell, indexRow: indexPath.row);
            }
            
            // Loads more item
            if ((self.arrayMessage.count - 1) == indexPath.row && self.arrayMessage.count >= Const.VALUE_PARAMS_LIMIT) {
                callApiGetTopic(isRefresh: true, completeReloadData: {
                    
                })
            }
            
            return mCell;
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView == mTblNotification) {
            var viewCell: UIView? = nil;
            var cell: UITableViewCell? = nil;
            
            let notification = self.arrayNotification[indexPath.row];
            if (notification.type == TypeNotification.Welcome.rawValue) {
                let mCell = tableView.cellForRow(at: indexPath) as! CellNotificationSystem;
                cell = mCell;
                viewCell = mCell.lblContent.superview!;
            } else {
                let mCell = tableView.cellForRow(at: indexPath) as! CellNotification;
                cell = mCell;
                viewCell = mCell.lblContent.superview!;
            }
            
            if (!notification.isRead) {
                callApiReadPush(notification: notification, completeReloadData: {
                    notification.isRead = !notification.isRead;
                    viewCell?.backgroundColor = UIColor.white;
                    cell?.backgroundColor = UIColor.white;
                    
                    if notification.type == 2 {
                        if let message = notification.lastMessage {
                            if (message.type ==  TypeMessage.Group.rawValue) {
                                if let topicId = message.topicId {
                                    let topic: Topic = Topic(id: topicId);
                                    let itemHome: ItemHome = ItemHome(user: User(), topic: topic);
                                    let chatVC = ChatGroupViewController();
                                    chatVC.notification = notification;
                                    chatVC.topicId = message.topicId;
                                    chatVC.itemHome = itemHome;
                                    
                                    self.navigationController?.pushViewController(chatVC, animated: true);
                                } else {
                                    print("TopicId nil")
                                }
                            }
                        }
                    } else if notification.type == 1 {
                        let detailPushVC = DetailPushViewController();
                        detailPushVC.objectNotification = notification;
                        self.navigationController?.pushViewController(detailPushVC, animated: true);
                    }
                });
            } else {
                if notification.type == 2 {
                    if let message = notification.lastMessage {
                        if (message.type ==  TypeMessage.Group.rawValue) {
                            if let topicId = message.topicId {
                                let topic: Topic = Topic(id: topicId);
                                let itemHome: ItemHome = ItemHome(user: User(), topic: topic);
                                let chatVC = ChatGroupViewController();
                                chatVC.topicId = message.topicId;
                                chatVC.itemHome = itemHome;
                                
                                self.navigationController?.pushViewController(chatVC, animated: true);
                            } else {
                                print("TopicId nil")
                            }
                        }
                    }
                } else if notification.type == 1 {
                    let detailPushVC = DetailPushViewController();
                    detailPushVC.objectNotification = notification;
                    self.navigationController?.pushViewController(detailPushVC, animated: true);
                }
            }
        } else {
            let mCell = tableView.cellForRow(at: indexPath) as! CellMessage;
            let message = self.arrayMessage[indexPath.row];
            let hasMessageUnread = message.messageUnread! > 0;
            
            if (hasMessageUnread) {
                message.messageUnread = 0;
                
                mCell.userName.superview?.backgroundColor = UIColor.white;
                mCell.backgroundColor = UIColor.white;
            }
            
            if (message.type ==  TypeMessage.Group.rawValue) {
                callApiTopicInfo(topicId: message.id!, completeReloadData: {
                    (topic) -> Void in
                    let itemHome: ItemHome = ItemHome(user: topic.userCreate!, topic: topic);
                    
                    let chatVC = ChatGroupViewController();
                    if (message.isOld != nil) {
                        chatVC.isLastPost = message.isOld!;
                    } else {
                        chatVC.isLastPost = false;
                    }
                    chatVC.itemHome = itemHome;
                    self.navigationController?.pushViewController(chatVC, animated: true);
                });
            } else {
                if let userAround: User = message.userAction {
                    self.callApiUsernfo(userId: userAround.id!, completeReloadData: {
                        (user) -> Void in
                        let chatVC = ChatOneViewController();
                        chatVC.userAround = user;
                        self.navigationController?.pushViewController(chatVC, animated: true);
                    });
                }
            }
            
        }
    }
    
    func createCellNotification(mCell: CellNotification, itemNotification: ObjectNotification) -> CellNotification {
        mCell.selectionStyle = UITableViewCellSelectionStyle.none;
        
        let userAction: User = itemNotification.userAction!;
        if (userAction.avatarSmall != nil) {
            mCell.imgAvatar.sd_setImage(with: URL(string: (userAction.avatarSmall)!), placeholderImage: UIImage(named: "avatar_no_image"));
        } else {
            mCell.imgAvatar.image = UIImage(named: "avatar_no_image");
        }
        //Circular image flag
        setCircleImage(imageView: mCell.imgFlag);
        
        //Circular image
        self.setCircleImage(imageView: mCell.imgAvatar);
        
        mCell.imgFlag.image = Utils.getFlagCountry(code: (userAction.codeCountry)!);
        
        let dateString = DateTimeUtils.getDateNotificationTime(second: itemNotification.createdTime!);
        mCell.lblDateTime.text = dateString;
        
        let strUsername = Utils.getFullName(user: userAction);
        let strContent = itemNotification.content!;
        
        let lengthUserName = strUsername.characters.count;
        
        let fontSize = mCell.lblContent.font.pointSize;
        var strContentStyle = NSMutableAttributedString();
        strContentStyle = NSMutableAttributedString(string: strUsername + strContent as String, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: fontSize)])
        
        strContentStyle.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: fontSize),range: NSRange(location: 0,length: lengthUserName));
        mCell.lblContent.attributedText = strContentStyle;
        
        if (itemNotification.isRead) {
            mCell.lblContent.superview?.backgroundColor = UIColor.white;
            mCell.backgroundColor = UIColor.white;
        } else {
            let color = UIColor(hexString: "#fff5c4");
            
            mCell.lblContent.superview?.backgroundColor = color;
            mCell.backgroundColor = color;
        }
        
        return mCell;
    }
    
    func createCellNotificationSystem(mCell: CellNotificationSystem, itemNotification: ObjectNotification) -> CellNotificationSystem {
        mCell.selectionStyle = UITableViewCellSelectionStyle.none;
        
        mCell.imgFlag.isHidden = true;
        mCell.imgAvatar.image = UIImage(named: "notification_system");
        
        mCell.lblContent.text = itemNotification.content;
        
        let dateCreated = DateTimeUtils.getDateNotificationTime(second: itemNotification.createdTime!);
        mCell.lblDateTime.text = dateCreated;
        
        if (itemNotification.isRead) {
            mCell.lblContent.superview?.backgroundColor = UIColor.white;
            mCell.backgroundColor = UIColor.white;
        } else {
            let color = UIColor(hexString: "#fff5c4");
            
            mCell.lblContent.superview?.backgroundColor = color;
            mCell.backgroundColor = color;
        }
        
        return mCell;
    }
    
    func createCellMessage(mCell: CellMessage, indexRow: Int) -> CellMessage {
        mCell.selectionStyle = UITableViewCellSelectionStyle.none;
        
        let itemMessage : ObjectMessage = self.arrayMessage[indexRow];
        let hasMessageUnread = itemMessage.messageUnread! > 0;
        
        if (itemMessage.type ==  TypeMessage.Group.rawValue) {
            if (itemMessage.userCreate != nil && itemMessage.userCreate?.avatarSmall != nil) {
                mCell.imgFlag.sd_setImage(with: URL(string: (itemMessage.userCreate?.avatarSmall)!), placeholderImage: UIImage(named: "avatar_no_image"));
            } else {
                mCell.imgFlag.image = UIImage(named: "avatar_no_image");
            }
            //Circular image flag
            setCircleImage(imageView: mCell.imgFlag);
            
            mCell.imgAvatar.image = Utils.getTopicFormType(typeTopic: itemMessage.category!);
            //Circular image flag
            setCircleImage(imageView: mCell.imgAvatar);

            setTextLabel(label: mCell.userName, text: itemMessage.title, isBold: hasMessageUnread, color: nil);
            
            let lastMessage = itemMessage.lastMessage;
            if (lastMessage != nil) {
                var content = "";
                if (lastMessage?.type != nil && lastMessage?.message != nil) {
                    if (lastMessage?.type == 3) {
                        content = StringUtilities.getLocalizedString("txt_is_image", comment: "");
                    } else if (lastMessage?.type == 2) {
                        content = StringUtilities.getLocalizedString("txt_is_share_location", comment: "");
                    } else {
                        content = (lastMessage?.message)!;
                    }
                }
                setTextLabel(label: mCell.content, text: content, isBold: false, color: nil);
            }
            
            let dateStyle = DateTimeUtils.getDateNotificationTime(second: itemMessage.lastMessage!.createdTime!);
            var color: UIColor!;
            if (!hasMessageUnread) {
                color = UIColor(hexString: "#bdbdbd");
            }
            setTextLabel(label: mCell.dateTime, text: dateStyle, isBold: false, color: color);
        } else {
            let userAction: User = itemMessage.userAction!;
            if (userAction.avatarSmall != nil) {
                mCell.imgAvatar.sd_setImage(with: URL(string: (userAction.avatarSmall)!), placeholderImage: UIImage(named: "avatar_no_image"));
            } else {
                mCell.imgAvatar.image = UIImage(named: "avatar_no_image");
            }
            //Circular image flag
            setCircleImage(imageView: mCell.imgFlag);
            
            //Circular image flag
            setCircleImage(imageView: mCell.imgAvatar);
            
            mCell.imgFlag.image = Utils.getFlagCountry(code: (userAction.codeCountry)!);
            
            setTextLabel(label: mCell.userName, text: Utils.getFullName(user: userAction), isBold: hasMessageUnread, color: nil);
            
            let lastMessage = itemMessage.lastMessage;
            if (lastMessage != nil) {
                var content = "";
                if (lastMessage?.type != nil && lastMessage?.message != nil) {
                    if (lastMessage?.type == 3) {
                        content = StringUtilities.getLocalizedString("txt_is_image", comment: "");
                    } else if (lastMessage?.type == 2) {
                        content = StringUtilities.getLocalizedString("txt_is_share_location", comment: "");
                    } else {
                        content = (lastMessage?.message)!;
                    }
                }
                setTextLabel(label: mCell.content, text: content, isBold: false, color: nil);
            }
            
            let dateStyle = DateTimeUtils.getDateNotificationTime(second: (itemMessage.lastMessage?.createdTime!)!);
            var color: UIColor!;
            if (!hasMessageUnread) {
                color = UIColor(hexString: "#bdbdbd");
            }
            setTextLabel(label: mCell.dateTime, text: dateStyle, isBold: false, color: color);
        }
        mCell.widthDateTime.constant = mCell.dateTime.intrinsicContentSize.width;
        
        if (hasMessageUnread) {
            let color = UIColor(hexString: "#fff5c4");
            
            mCell.userName.superview?.backgroundColor = color;
            mCell.backgroundColor = color;
        } else {
            mCell.userName.superview?.backgroundColor = UIColor.white;
            mCell.backgroundColor = UIColor.white;
        }
        
        return mCell;
    }
    
    /*
     * Circular image flag
     */
    func setCircleImage(imageView : UIImageView){
        imageView.layer.cornerRadius = imageView.frame.size.width / 2;
        imageView.clipsToBounds = true;
    }
    
    func setTextLabel(label: UILabel, text: String!, isBold: Bool, color: UIColor?) {
        let fontSize = label.font.pointSize;
        label.attributedText = getTextStyle(text: text, isBold: isBold, fontSize: fontSize, color: color);
    }
    
    func getTextStyle(text: String!, isBold: Bool, fontSize: CGFloat, color: UIColor?) -> NSMutableAttributedString {
        if (isBold) {
            var attrs = Dictionary<String, Any>();
            attrs.updateValue(UIFont.boldSystemFont(ofSize: fontSize), forKey: NSFontAttributeName);
            if (color != nil) {
                attrs.updateValue(color!, forKey: NSForegroundColorAttributeName);
            }
            let attributedString = NSMutableAttributedString(string:text, attributes:attrs);
            
            return attributedString;
        } else {
            var attrs = Dictionary<String, Any>();
            if (color != nil) {
                attrs.updateValue(color!, forKey: NSForegroundColorAttributeName);
            }
            let normalString = NSMutableAttributedString(string:text, attributes: attrs);
            
            return normalString;
        }
    }
    
    func callApiGetTopic(isRefresh : Bool, completeReloadData : @escaping () -> Void){
        if (isRefresh == false) {
            self.arrayMessage.removeAll();
        }
        var params : Dictionary = Dictionary<String, String>();
        if (mUser == nil) {
            return;
        }
        params.updateValue((mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
        params.updateValue(String(self.arrayMessage.count), forKey: Const.KEY_PARAMS_OFFSET);
        params.updateValue(String(Const.VALUE_PARAMS_LIMIT), forKey: Const.KEY_PARAMS_LIMIT);
        
        APIClient.sharedInstance.postRequest(Url: URL_TOPICS_RELATIVE, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: true, ShowAlert: true, Success: { (success : AnyObject) in
            let responseJson = JSON(success);
            
            let listTopicRelative = responseJson[Const.KEY_RESPONSE_DATA].arrayValue;
            let paserHelper : ParserHelper = ParserHelper();
            for itemTopicRelative in listTopicRelative {
                let topicRelative : ObjectMessage = paserHelper.pareserModel(data: itemTopicRelative);
                
                self.arrayMessage.append(topicRelative);
            }
            if (listTopicRelative.count > 0) {
                self.mTblMessage.reloadData();
            }
            
            self.lblNoDataMessage.isHidden = self.arrayMessage.count > 0;
            if (!self.lblNoDataMessage.isHidden) {
                self.mTblMessage.reloadData();
            }
            
            let unread : UnreadResponse = paserHelper.pareserModel(data: responseJson[Const.KEY_RESPONSE_UNREAD]);
            let objSetTabbar = NotificationSetInfoBadgeTabbar(badge: unread.total);
            NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_SET_BADGE_TAB, object: objSetTabbar, userInfo: nil);
            
            completeReloadData();
        }) { (error : AnyObject?) in
            self.mTblMessage.reloadData();
            self.mRefreshControlMessage.endRefreshing();
        }
    }
    
    func callApiGetPush(isRefresh : Bool, completeReloadData : @escaping () -> Void) {
        if (isRefresh == false) {
            self.arrayNotification.removeAll();
        }
        var params : Dictionary = Dictionary<String, String>();
        if (mUser == nil) {
            return;
        }
        params.updateValue((mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
        params.updateValue(String(self.arrayNotification.count), forKey: Const.KEY_PARAMS_OFFSET);
        params.updateValue(String(Const.VALUE_PARAMS_LIMIT), forKey: Const.KEY_PARAMS_LIMIT);
        
        APIClient.sharedInstance.postRequest(Url: URL_GET_PUSH, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: true, ShowAlert: true, Success: { (success : AnyObject) in
            let responseJson = JSON(success);
            
            let listNotification = responseJson[Const.KEY_RESPONSE_DATA].arrayValue;
            let paserHelper : ParserHelper = ParserHelper();
            
            for itemNotifitcation in listNotification {
                let notification : ObjectNotification = paserHelper.pareserModel(data: itemNotifitcation);
                
                self.arrayNotification.append(notification);
            }
            if (listNotification.count > 0) {
                self.mTblNotification.reloadData();
            }
            
            self.lblNoDataNotification.isHidden = self.arrayNotification.count > 0;
            if (!self.lblNoDataNotification.isHidden) {
                self.mTblNotification.reloadData();
            }
            
            let unread : UnreadResponse = paserHelper.pareserModel(data: responseJson[Const.KEY_RESPONSE_UNREAD]);
            let objSetTabbar = NotificationSetInfoBadgeTabbar(badge: unread.total);
            NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_SET_BADGE_TAB, object: objSetTabbar, userInfo: nil);
            
            completeReloadData();
        }) { (error : AnyObject?) in
            self.mTblNotification.reloadData();
            self.mRefreshControlNotification.endRefreshing();
        }
    }
    
    func callApiReadPush(notification: ObjectNotification, completeReloadData : @escaping () -> Void) {
        var params : Dictionary = Dictionary<String, String>();
        if (mUser == nil) {
            return;
        }
        params.updateValue((mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
        params.updateValue(notification.id, forKey: Const.KEY_PARAMS_PUSH_ID);
        
        APIClient.sharedInstance.postRequest(Url: URL_READ_PUSH, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: true, ShowAlert: true, Success: { (success : AnyObject) in
            completeReloadData();
        }) { (error : AnyObject?) in
            completeReloadData();
        }
    }
    
    private func callApiTopicInfo(topicId: String, completeReloadData : @escaping (_ topic: Topic) -> Void) {
        var params : Dictionary = Dictionary<String, String>();
        if (mUser == nil) {
            return;
        }
        params.updateValue((mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
        params.updateValue(topicId, forKey: Const.KEY_PARAMS_TOPIC_ID);
        
        APIClient.sharedInstance.postRequest(Url: URL_TOPIC_INFO, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: true, ShowAlert: true, Success: { (success : AnyObject) in
            let responseJson = JSON(success);
            
            let topicInfo = responseJson[Const.KEY_RESPONSE_DATA];
            let paserHelper : ParserHelper = ParserHelper();
            
            let topic: Topic = paserHelper.pareserModel(data: topicInfo);
            completeReloadData(topic);
        }) { (error : AnyObject?) in
            let response = JSON(error!);
            let errorCode : String? = response["error_code"].rawString();
            if (errorCode != nil && errorCode == String(APIError.TopicIsDeleted)) {
                self.callApiGetTopic(isRefresh: false, completeReloadData: {
                    self.mRefreshControlMessage.endRefreshing();
                });
            }
        }
    }
    
    private func callApiUsernfo(userId: String, completeReloadData : @escaping (_ user: User) -> Void) {
        var params : Dictionary = Dictionary<String, String>();
        if (mUser == nil) {
            return;
        }
        params.updateValue(userId, forKey: Const.KEY_PARAMS_USER_ID);
        
        APIClient.sharedInstance.postRequest(Url: URL_USER_INFO, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: true, ShowAlert: true, Success: { (success : AnyObject) in
            
            let responseJson = JSON(success)["data"];
            let paserHelper : ParserHelper = ParserHelper();
            
            let userAround: User = paserHelper.pareserModel(data: responseJson);
            
            completeReloadData(userAround);
            
        }) { (error : AnyObject?) in
            if let objError = error {
                let response = JSON(objError);
                let errorCode : String? = response["error_code"].rawString();
                if (errorCode != nil && errorCode == String(APIError.UserIsDeleted)) {
                    self.callApiGetTopic(isRefresh: false, completeReloadData: {
                        self.mRefreshControlMessage.endRefreshing();
                    });
                }
            }
        }
    }
    
    @objc private func catchNotification(notification: NSNotification) {
        print("receiver notification");
        if (!self.viewNotification.isHidden || (self.viewNotification.isHidden && self.arrayNotification.count > 0)) {
            let dataNotification = notification.object as! ObjectNotification;
            print("data: " + dataNotification.toJSONString()!);
            self.arrayNotification.insert(dataNotification, at: 0);
            self.mTblNotification.reloadData();
        }
    }
    
    @objc private func catchMessage(notification: NSNotification) {
        print("receiver message");
        if (!self.viewMessage.isHidden || (self.viewMessage.isHidden && self.arrayMessage.count > 0)) {
            let dataMessage = notification.object as! ObjectMessage;
            print("data: " + dataMessage.toJSONString()!);
            for index in 0..<self.arrayMessage.count {
                if (dataMessage.id == self.arrayMessage[index].id) {
                    self.arrayMessage.remove(at: index);
                    break;
                }
            }
            self.arrayMessage.insert(dataMessage, at: 0);
            self.mTblMessage.reloadData();
        }
    }
}

