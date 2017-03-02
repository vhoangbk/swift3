/**
 * APIClient
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */


import Foundation
import Alamofire
import SwiftyJSON
import FacebookLogin

let URL_BASE : String = Const.SERVER_URL + "/api/";

let URL_LOGIN : String = URL_BASE + "login";

let URL_TOPICS : String = URL_BASE + "topics";

let URL_REGISTER : String = URL_BASE + "add_user";

let URL_USER_AROUND : String = URL_BASE + "user_nearby";

let URL_UPLOAD_IMAGE : String = URL_BASE + "upload_image";

let URL_RESET_PASSWORD : String = URL_BASE + "reset_password";

let URL_UPDATE_USER : String = URL_BASE + "update_user_info";

let URL_USER_START_CHAT : String = URL_BASE + "start_chat";

let URL_USER_CHECK_BLOCK_TOPIC : String = URL_BASE + "check_block_topic";

let URL_OLD_TOPICS : String = URL_BASE + "old_topic";

let URL_LOGOUT : String = URL_BASE + "logout";

let URL_CHANGE_PASSWORD : String = URL_BASE + "change_password";

let URL_USER_INFO : String = URL_BASE + "user_info";

let URL_BLOCK_USER : String = URL_BASE + "block_user";

let URL_UNBLOCK_USER : String = URL_BASE + "unblock_user";

let URL_ADD_TOPICS : String = URL_BASE + "add_topic";

let URL_TOPICS_RELATIVE : String = URL_BASE + "topics_relative";

let URL_GET_PUSH : String = URL_BASE + "get_push";

let URL_READ_PUSH : String = URL_BASE + "read_push";

let URL_USER_LOCATION_SHARE_TIME = URL_BASE + "get_time_expired_location";

let URL_GET_UNREAD_TOTAL : String = URL_BASE + "get_unread_total";

let URL_TOPIC_INFO : String = URL_BASE + "topic_info";

let URL_ACTIVE_PREMIUM : String = URL_BASE + "active_premium";

let URL_BASE_FACEBOOK_GRAPH : String = "https://graph.facebook.com/v2.8/";

class APIClient {
    
    static let sharedInstance = APIClient()
   
    func postRequest(Url url : String, Parameters params : [String : AnyObject], ViewController viewController : UIViewController, ShowProgress isShowProgress : Bool, ShowAlert isShowAlert : Bool, Success success : @escaping (AnyObject) -> Void, Failure failure : @escaping (AnyObject?)->Void ) {
        let languageCode = NSLocale.current.languageCode;
        var strLanguageCode = "en";
        if(languageCode != nil) {
            strLanguageCode = languageCode!;
        }
        var paramsNew : Dictionary = Dictionary<String, Any>();
        paramsNew.updateValue(strLanguageCode, forKey: Const.KEY_PARAMS_PHONE_LANGUAGE);
        let resultParams = params.merged(with: paramsNew as Dictionary<String, AnyObject>);
        
        NSLog("[URL] " + url);
        NSLog("[PARAM] \(JSON(resultParams))");
        
        if (isShowAlert) {
            if ( !Utils.isInternetAvailable() ){
                Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("message_error_network", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: viewController, actionOK: nil);
                failure(nil)
                return;
            }
            
        }
        
        if isShowProgress {
            MBProgressHUD.showAdded(to: viewController.view, animated: true);
        }
        
        let headers = [
            "Accept": "application/json",
            "Content-Type" : "application/json"
        ]
    
        Alamofire.request(url, method: .post, parameters: resultParams, encoding: JSONEncoding.default, headers : headers).responseJSON { (response : DataResponse<Any>) in
            DispatchQueue.main.async(execute: {
                MBProgressHUD.hide(for: viewController.view, animated: true);
                switch response.result {
                case .success:
                    if let json = response.result.value {
                        let response = JSON(json);
                        NSLog("[RESPONSE] \(response)");
                        let result = response["result"];
                        if (result == 0){
                            success(json as AnyObject)
                        }else{
                            var mes : String? = response["message"].rawString()!;
                            let errorCode : String? = response["error_code"].rawString();
                            
                            if (errorCode != nil ){
                                let apiError = APIError();
                                if apiError.hasErrorCode(errorCode: errorCode!){
                                    mes = apiError.getMessage(errorCode: errorCode!);
                                }else{
                                    //error_code_common_with_error_code
                                    mes = String(format: StringUtilities.getLocalizedString("error_code_common_with_error_code", comment: ""), errorCode!);
                                }
                            }else{
                                mes = StringUtilities.getLocalizedString("error_code_common", comment: "");
                            }
                            
                            failure(json as AnyObject?)
                            if (isShowAlert){
                                if (errorCode != "null" && APIError.UserIsDeleted == Int(errorCode!)!){
                                    Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("user_is_deleted", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: viewController, actionOK: { (UIAlertAction) in
                                            if ((viewController.navigationController?.viewControllers.count)! > 1){
                                                viewController.navigationController!.popViewController(animated: true);
                                            }else{
                                                viewController.dismiss(animated: true, completion: nil);
                                            }
                                        })
                                    return;
                                }
                                
                                Utils.showAlertWithTitle("", message: mes!, titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: viewController, actionOK: { (action : UIAlertAction) in
                                    let apiError = APIError();
                                    if (apiError.isLoginFail(errorCode: errorCode!)){
                                        
                                        let loginManager = LoginManager();
                                        loginManager.logOut();
                                        Utils.setPremium(isPremium: false)
                                        
                                        Utils.setInfoAccount(infoAccount: nil);
                                        Utils.setApiKey(token: "");
                                        
                                        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
                                        appDelegate.mUser = nil;
                                        let login = LoginViewController();
                                        let naviVC = UINavigationController(rootViewController: login);
                                        appDelegate.window?.rootViewController = naviVC;
                                        appDelegate.window?.makeKeyAndVisible();
                                    }
                                    
                                })
                            }
                            
                        }
                    }
                    break;
                case .failure(let error):
                    NSLog("[RESPONSE ERROR] \(error)");
                    if error._code == NSURLErrorTimedOut {
                        NSLog("[RESPONSE ERROR] timeout");
                    }
                    if (isShowProgress){
                        MBProgressHUD.hide(for: viewController.view, animated: true);
                    }
                    failure(nil)
                    if(isShowAlert){
                        Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("error_code_common", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: viewController, actionOK: nil);
                    }
                    
                    break;
                }
                
            });
        }
    }
    
    func uploadImage(image : UIImage, isShowAlert : Bool, viewController : UIViewController, isChat : Bool, name : String, Success success : @escaping (AnyObject) -> Void, Failure failure : @escaping (AnyObject?)->Void ) {
        
        if (isShowAlert) {
            if ( !Utils.isInternetAvailable() ){
                Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("message_error_network", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: viewController, actionOK: nil);
                failure(nil)
                return;
            }
            
        }
        
        let imageData : Data;
        
        if (isChat){
            imageData = getDataFormImage(image: image, maxVal: 5.0)
        }else{
            imageData = getDataFormImage(image: image, maxVal: 2.0);
        }
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageData, withName: "mypicture", fileName: name, mimeType: "image");
                multipartFormData.append(Utils.getApiKey().data(using: String.Encoding.utf8)!, withName: "api_key", mimeType: "text");
                
                if (isChat){
                    multipartFormData.append("true".data(using: String.Encoding.utf8)!, withName: "image_chat", mimeType: "text");
                }
                
            },
            to: URL_UPLOAD_IMAGE,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if (response.result.value == nil){
                            if (isShowAlert){
                                Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("image_upload_fail", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: viewController, actionOK: nil);
                            }
                            failure(nil)
                            return;
                        }
                        let jsonResponse = JSON(response.result.value!);
                        let result = jsonResponse["result"].intValue;
                        if (result == 0){
                            success(response.result.value as AnyObject)
                        }else{
                            if (isShowAlert){
                                Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("image_upload_fail", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: viewController, actionOK: nil);
                            }
                            failure(response.result.value as AnyObject?)
                        }
                    }
                case .failure( _):
                    if (isShowAlert){
                        Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("image_upload_fail", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: viewController, actionOK: nil);
                    }
                    failure(nil)
                }
            }
        )
    }
    
    func getRequest(Url url : String, ViewController viewController : UIViewController, ShowProgress isShowProgress : Bool, ShowAlert isShowAlert : Bool, Success success : @escaping (AnyObject) -> Void, Failure failure : @escaping (AnyObject?)->Void ) {
        
        print("[URL] Get: " + url);
        
        if (isShowAlert) {
            if ( !Utils.isInternetAvailable() ){
                Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("message_error_network", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: viewController, actionOK: nil);
                failure(nil)
                return;
            }
            
        }
        
        if isShowProgress {
            MBProgressHUD.showAdded(to: viewController.view, animated: true);
        }
        
        Alamofire.request(url, method: .get).responseJSON { (response : DataResponse<Any>) in
            DispatchQueue.main.async(execute: {
                MBProgressHUD.hide(for: viewController.view, animated: true);
                switch response.result {
                case .success:
                    if let json = response.result.value {
                        print("[RESPONSE] \(json)");
                        let response = JSON(json);
                        let status = response["status"].stringValue;
                        if (status == "OK"){
                            success(json as AnyObject)
                        }else{
                            failure(json as AnyObject?)
                            if (isShowAlert){
                                Utils.showAlertWithTitle("", message: status, titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: viewController, actionOK: { (action : UIAlertAction) in
                                })
                            }
                            
                        }
                    }
                    break;
                case .failure(let error):
                    if error._code == NSURLErrorTimedOut {
                        print("Time out");
                    }
                    if (isShowProgress){
                        MBProgressHUD.hide(for: viewController.view, animated: true);
                    }
                    failure(nil)
                    if(isShowAlert){
                        Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("error_code_common", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: viewController, actionOK: nil);
                    }
                    
                    break;
                }
                
            });
        }
        
    }
    
    func getData(Url url : String, ViewController viewController : UIViewController, ShowProgress isShowProgress : Bool, ShowAlert isShowAlert : Bool, Success success : @escaping (AnyObject) -> Void, Failure failure : @escaping (AnyObject?)->Void ) {
        
        print("[URL] Get: " + url);
        
        if (isShowAlert) {
            if ( !Utils.isInternetAvailable() ){
                Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("message_error_network", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: viewController, actionOK: nil);
                failure(nil)
                return;
            }
            
        }
        
        if isShowProgress {
            MBProgressHUD.showAdded(to: viewController.view, animated: true);
        }
        
        Alamofire.request(url, method: .get).responseJSON { (response : DataResponse<Any>) in
            DispatchQueue.main.async(execute: {
                MBProgressHUD.hide(for: viewController.view, animated: true);
                switch response.result {
                case .success:
                    if let json = response.result.value {
                        print("[RESPONSE] \(json)");
                        let response = JSON(json);
                        if ((response["error"].null) != nil){
                            success(json as AnyObject)
                        }else{
                            failure(json as AnyObject?)
                            if (isShowAlert){
                                Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("error_code_common", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: viewController, actionOK: { (action : UIAlertAction) in
                                })
                            }
                            
                        }
                    }
                    break;
                case .failure(let error):
                    if error._code == NSURLErrorTimedOut {
                        print("Time out");
                    }
                    if (isShowProgress){
                        MBProgressHUD.hide(for: viewController.view, animated: true);
                    }
                    failure(nil)
                    if(isShowAlert){
                        Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("error_code_common", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: viewController, actionOK: nil);
                    }
                    
                    break;
                }
                
            });
        }
        
    }
    
    func getDataFormImage(image : UIImage, maxVal : Float) -> Data {
        let imagecompresor = ImageCompresor();
        imagecompresor.image = image;
        imagecompresor.shrinkImage(maxVal);
        return imagecompresor.data;
    }
    
    func createUrlFacebookHomeTown(homeTownId : String, accessToken : String) -> String {
        let urlFacebook = URL_BASE_FACEBOOK_GRAPH + homeTownId + "?fields=location&access_token=" + accessToken;
        return urlFacebook;
    }
}
