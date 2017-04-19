
import UIKit

class TabbarViewController : UITabBarController {
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.setupViewController()
    }
    
    func setupViewController() {
        let titleArray = ["支出","收入","转账","我的","设置"]
        let viewControllerArray = [
            PayViewController(),
            IncomeViewController().inittitle(),
            TransfViewController().inittitle(),
            MyViewController().inittitle(),
            ConfViewController().inittitle()
        ]
        let normalImagesArray = [UIImage(named:"expense"),UIImage(named:"income"),UIImage(named:"transfer"),UIImage(named:"bank"),UIImage(named:"config")]
        
        let navigationVCArray = NSMutableArray()
        for (index, controller) in viewControllerArray.enumerated() {
            controller.tabBarItem.title = titleArray[index]
            controller.tabBarItem.image = normalImagesArray[index]
            let navigationController = UINavigationController(rootViewController: controller)
            navigationVCArray.add(navigationController)
            //controller.tabBarItem!.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.gray], for: .normal)
            //controller.tabBarItem!.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.red], for: .selected)
        }
        
        self.viewControllers = navigationVCArray.mutableCopy() as! [UINavigationController]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
