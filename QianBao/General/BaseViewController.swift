import UIKit
protocol BaseViewControllerDelegate : class {
    
}

class BaseViewController: UIViewController, BaseViewControllerDelegate {
    weak var delegate : BaseViewControllerDelegate?
    var routingParams: AnyObject?
    
    
}
