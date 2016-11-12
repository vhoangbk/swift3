//
//  ChatViewController.swift
//  Locozap
//
//  Created by paraline on 10/12/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import UIKit

class ChatViewController: JSQMessagesViewController {
    
    let socketManager = SocketIOManager.sharedInstance;
    
    var historyList = [History] ();
    
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    
    var mUser : User?;
    
    var isTyping : Bool = false;
    var timer : Timer?;
    static let timeoutTyping = 0.6;
    
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar();
        
        // Bubbles with tails
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor(netHex: 0xe5e5ea));
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor(netHex: 0xfed303));
        
        if (mUser == nil && Utils.getInfoAccount() != nil){
            let appDelegate = UIApplication.shared.delegate as! AppDelegate;
            mUser = appDelegate.mUser;
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true);
    }
    
    func initNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = UIColor(netHex: Const.COLOR_PRIMARY);
        let backButton = UIBarButtonItem(image: UIImage(named: "img_back")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ChatOneViewController.didPressBack));
        self.navigationItem.leftBarButtonItem = backButton;
        
        let navFont : UIFont?;
        let language = NSLocale.preferredLanguages.first;
        if language?.hasPrefix("ja") == true {
            navFont = UIFont(name: Const.HIRAKAKUPRO_W6, size: 13);
        }else{
            navFont = UIFont.systemFont(ofSize: 13);
        }
        
        let navBarAttributesDictionary: [String: AnyObject]? = [
            (NSForegroundColorAttributeName as NSObject) as! String: UIColor(netHex: Const.COLOR_WHITE),
            (NSFontAttributeName as NSObject) as! String: navFont!
        ]
        self.navigationController?.navigationBar.titleTextAttributes = navBarAttributesDictionary;
        
    }
    
    func didPressBack() {
        self.navigationController!.popViewController(animated: true);
    }
    
    func openPhoto() {
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func openCamera() {
        //check simulator
        #if (arch(i386) || arch(x86_64))
            
        #else
            imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        #endif
    }
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView, didTapLink nsUrl: URL) {
        let webviewVC = WebViewViewController();
        webviewVC.url = nsUrl;
        self.present(webviewVC, animated: true, completion: nil)
	}

    //MARK: JSQMessagesCollectionViewDelegateFlowLayout
    override func collectionView(_ collectionView: JSQMessagesCollectionView, didTapMessageBubbleAt indexPath: IndexPath) {
        print("didTapMessageBubbleAt")
        let message : Message = historyList[indexPath.row].message!
        if Message.MESSAGE_SERVER_TYPE_TEXT == message.type {
            print("message: " + message.message!)
        }else if Message.MESSAGE_SERVER_TYPE_IMAGE == message.type {
            print("image: " + message.message!)
            
            let imageview = UIImageView();
            imageview.sd_setImage(with: URL.init(string: message.message!)) { (image, error, type, url) in
                let imageVC = TGRImageViewController(image: image);
                self.present(imageVC!, animated: true, completion: nil);
                
            }

            
        }else if Message.MESSAGE_SERVER_TYPE_LOCATION == message.type {
            print("location: " + message.latitude! + "," + message.longitude!);
            openMapForPlace(lat: Double(message.latitude!)!, lon: Double(message.longitude!)!);
        }
    }
	
    /**
     * Open map
     *
     */
    func openMapForPlace(lat : Double, lon : Double) {
        
        let latitude:CLLocationDegrees =  lat;
        let longitude:CLLocationDegrees =  lon;
        let regionDistance:CLLocationDistance = 1000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "";
        mapItem.openInMaps(launchOptions: options)
        
    }
}
