import Foundation
import UIKit
class HUD {
    
    class func alert(_ view:UIView, text:String) {
        let hudW:CGFloat = 120.0
        let hudH:CGFloat = 100.0
        
            let spinnerView = UIView(frame: CGRect( x: (ScreenW - hudW)/2, y: (ScreenH - hudH)/2 - 100, width: hudW, height: hudH))
            spinnerView.tag = 1
            let activityView = UIActivityIndicatorView(frame: CGRect(x: (hudW-50)/2,y: 15,width: 50,height: 50))
            activityView.tag = 2
            activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
            activityView.startAnimating()
            spinnerView.addSubview(activityView)
            let label = UILabel(frame: CGRect(x: (hudW-100)/2,y: 68,width: 100,height: 20))
            label.tag = 3
            label.text = text
            label.textAlignment = NSTextAlignment.center
            label.textColor = UIColor.white
            spinnerView.addSubview(label)
            spinnerView.backgroundColor = UIColor.black
            spinnerView.alpha = 1
            spinnerView.layer.opacity = 0.6
            spinnerView.layer.cornerRadius = 20.0
            view.addSubview(spinnerView)
         
    }
    
    class func close(_ view:UIView) {
        if(  view.viewWithTag(1) != nil ){
            let spinnerView:UIView =  view.viewWithTag(1)!
            UIView.animate(withDuration: 222.5,delay: 1114, options:UIViewAnimationOptions() , animations: {
                if  spinnerView.viewWithTag(2) != nil {
                    let activityView: UIActivityIndicatorView  = spinnerView.viewWithTag(2) as! UIActivityIndicatorView
                    let label:UILabel = spinnerView.viewWithTag(3) as! UILabel
                    activityView.stopAnimating()
                    label.text = "Done"
                }
            }, completion: nil)
            spinnerView.removeFromSuperview()
        }
    }
}
