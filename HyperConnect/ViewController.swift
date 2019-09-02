
import UIKit
import ElastosCarrierSDK
import MaterialComponents.MaterialBottomNavigation
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var bottomBarView: UIView!
    
    var bottomBar:MDCBottomNavigationBar!
    
    var pageController:UIPageViewController!
    fileprivate lazy var pages: [UIViewController] = {
        return [
            self.getViewController(withIdentifier: "dashboardView"),
            self.getViewController(withIdentifier: "devicesView"),
            self.getViewController(withIdentifier: "eventsView")
        ]
    }()
    var currentPageIndex:Int=0
    
    fileprivate func getViewController(withIdentifier identifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initBottomBar()
        initPageController()
    }
    
    func initBottomBar(){
        bottomBar=MDCBottomNavigationBar(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: bottomBarView.bounds.width, height: 56.0)))
        bottomBar.items = [
            UITabBarItem(title: "Dashboard", image: UIImage(named: "imageDashboard"), tag: 0),
            UITabBarItem(title: "Devices", image: UIImage(named: "imageDevices"), tag: 1),
            UITabBarItem(title: "Events", image: UIImage(named: "imageEvent"), tag: 2)
        ]
        bottomBar.barTintColor = UIColor.init(named: "colorMetal")
        bottomBar.tintColor = UIColor.white
        bottomBar.selectedItemTintColor = UIColor.white
        bottomBar.unselectedItemTintColor = UIColor.init(named: "colorGray")!
        bottomBar.alignment = .justified
        bottomBar.titleVisibility = .always
        bottomBar.elevation = ShadowElevation.init(rawValue: 0)
        bottomBar.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        bottomBar.sizeToFit()
        bottomBar.delegate=self
        bottomBarView.addSubview(bottomBar)
    }
    
    func initPageController() {
        pageController.delegate=self
        pageController.dataSource=self
        for page in pages {
            pageController.setViewControllers([page], direction: .forward, animated: true, completion: nil)
        }
        pageController.setViewControllers([pages[currentPageIndex]], direction: .forward, animated: true, completion: nil)
        let bottomBarItem=bottomBar.items[currentPageIndex]
        bottomBar.selectedItem=bottomBarItem
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="actionPageControl" {
            pageController=segue.destination as? UIPageViewController
        }
        else if segue.identifier=="actionNotifications" {
            let notificationsVC=segue.destination as! NotificationsViewController
            notificationsVC.fromPageIndex=currentPageIndex
        }
    }
}


extension ViewController: MDCBottomNavigationBarDelegate{
    func bottomNavigationBar(_ bottomNavigationBar: MDCBottomNavigationBar, didSelect item: UITabBarItem) {
        let index:Int! = item.tag
        if index != currentPageIndex {
            if index > currentPageIndex {
                pageController.setViewControllers([pages[index]], direction: .forward, animated: true, completion: nil)
            }
            else {
                pageController.setViewControllers([pages[index]], direction: .reverse, animated: true, completion: nil)
            }
        }
        currentPageIndex=index
    }
}


extension ViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex=pages.firstIndex(of: viewController) else { return nil }
        
        if viewControllerIndex == 0 {
            return nil
        }
        
        let previousIndex=viewControllerIndex-1
        
        guard previousIndex >= 0 else { return pages.last }
        
        guard pages.count > previousIndex else { return nil }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex=pages.firstIndex(of: viewController) else { return nil }
        
        if viewControllerIndex == 2 {
            return nil
        }
        
        let nextIndex=viewControllerIndex+1
        
        guard nextIndex < pages.count else { return pages.first }
        
        guard pages.count > nextIndex else { return nil }
        
        return pages[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        let pageContentViewController=pageViewController.viewControllers![0]
        let viewControllerIndex=pages.firstIndex(of: pageContentViewController)
        currentPageIndex=viewControllerIndex!
        
        if finished && completed {
            let bottomBarItem=bottomBar.items[currentPageIndex]
            bottomBar.selectedItem=bottomBarItem
        }
    }
}
