/**
 * RatingBar
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
class RatingBar: UIView {
    
    @IBInspectable var rating: CGFloat = 0{//当前数值
        didSet{
            if 0 > rating {rating = 0}
            else if ratingMax < rating {rating = ratingMax}
            //回调给代理
            delegate?.ratingDidChange(ratingBar: self, rating: rating)

            self.setNeedsLayout()
        }
    }
    @IBInspectable var ratingMax: CGFloat = 5//总数值,必须为numStars的倍数
    @IBInspectable var numStars: Int = 5 //星星总数
    @IBInspectable var canAnimation: Bool = false//是否开启动画模式
    @IBInspectable var animationTimeInterval: TimeInterval = 0.2//动画时间
    @IBInspectable var incomplete:Bool = false//评分时是否允许不是整颗星星
    @IBInspectable var isIndicator:Bool = false//RatingBar是否是一个指示器（用户无法进行更改）
    @IBInspectable var paddingStar:Int = 0
    
    @IBInspectable var imageLight: UIImage = UIImage(named: "ic_start_activated")!
    @IBInspectable var imageDark: UIImage = UIImage(named: "ic_start_normal")!

    var isSlectStart : Bool = false;
    
    var foregroundRatingView: UIView!
    var backgroundRatingView: UIView!
    
    var delegate: RatingBarDelegate?
    var isDrew = false
    
    func buildView(){
        if isDrew {return}
        isDrew = true
        //创建前后两个View，作用是通过rating数值显示或者隐藏“foregroundRatingView”来改变RatingBar的星星效果
        self.backgroundRatingView = self.createRatingView(image: imageDark)
        self.foregroundRatingView = self.createRatingView(image: imageLight)
        animationRatingChange()
        self.addSubview(self.backgroundRatingView)
        self.addSubview(self.foregroundRatingView)
        
        //加入单击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapRateView(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        buildView()
        let animationTimeInterval = self.canAnimation ? self.animationTimeInterval : 0
        //开启动画改变foregroundRatingView可见范围
        UIView.animate(withDuration: animationTimeInterval, animations: {self.animationRatingChange()})
    }
    //改变foregroundRatingView可见范围
    func animationRatingChange(){
        let realRatingScore = self.rating / self.ratingMax
        self.foregroundRatingView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width * realRatingScore, height: self.bounds.size.height)

    }
    //根据图片名，创建一列RatingView
    func createRatingView(image: UIImage) ->UIView {
        let view = UIView(frame: self.bounds)
        view.clipsToBounds = true
        view.backgroundColor = UIColor.clear
        //开始创建子Item,根据numStars总数
        
        let positionY = CGFloat(0)
        let widthView = self.bounds.size.width - CGFloat((numStars - 1) * self.paddingStar)
        let widthItem = widthView / CGFloat(numStars)
        let height = self.bounds.size.height
        
        for position in 0 ..< numStars {
            let imageView = UIImageView(image: image)
            
            let positionX = CGFloat(position) * widthItem + CGFloat(position * self.paddingStar)
            
            imageView.frame = CGRect(x: positionX, y: positionY, width: widthItem, height: height);
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            
            view.addSubview(imageView)
        }
        
        return view
    }
    //点击编辑分数后，通过手势的x坐标来设置数值
    func tapRateView(_ sender : UITapGestureRecognizer){
        if(isSlectStart) {
            if isIndicator {return}//如果是指示器，就不能交互
            let tapPoint = sender.location(in: self)
            let widthView = self.backgroundRatingView.bounds.size.width - CGFloat((numStars - 1) * self.paddingStar)
            let widthOneStar = widthView / CGFloat(numStars)
            
            let offset = tapPoint.x
            var realRatingScore = 0;
            for i in 1...numStars {
                let startStar = CGFloat(i - 1) * widthOneStar + CGFloat((i - 1) * self.paddingStar)
                let endStar = startStar + widthOneStar
                
                if (offset > startStar && offset <= endStar) {
                    realRatingScore = i;
                    break;
                }
            }
            //通过x坐标判断分数
//            let realRatingScore = offset / (self.bounds.size.width / ratingMax);
//            self.rating = self.incomplete ? realRatingScore : round(Double(realRatingScore))
            if (realRatingScore > 0) {
                self.rating = CGFloat(realRatingScore);
            }
        }
    }
}
protocol RatingBarDelegate{
    func ratingDidChange(ratingBar: RatingBar,rating: CGFloat)
}
