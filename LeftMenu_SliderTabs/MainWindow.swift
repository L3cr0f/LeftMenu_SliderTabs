import UIKit

class MainWindow : UIViewController {
    
    // This value matches the left menu's width in the Storyboard
    let leftMenuWidth:CGFloat = 260
    
    // Need a handle to the scrollView to open and close the menu
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ContainerView: UIView!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!

    var myPageViewController: MyPageViewController?{
        didSet {
            myPageViewController?.myDelegate = self
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Initially close menu programmatically.  This needs to be done on the main thread initially in order to work.
        dispatch_async(dispatch_get_main_queue()) {
            self.closeMenu(false)
        }
                
        // Tab bar controller's child pages have a top-left button toggles the menu
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "menuButtonPressed", name: "menuButtonPressed", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "closeMenuViaNotification", name: "closeMenuViaNotification", object: nil)
        
        // Close the menu when the device rotates
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        // LeftMenu sends openModalWindow
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "openModalWindow", name: "openModalWindow", object: nil)
        
        // Selected First Tab
        firstButton.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)

    }
    
    // Cleanup notifications added in viewDidLoad
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func openModalWindow(){
        performSegueWithIdentifier("openModalWindow", sender: nil)
    }
    
    // Buttons
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let myPageViewController = segue.destinationViewController as? MyPageViewController {
            self.myPageViewController = myPageViewController
        }
    }
    
    @IBAction func firstButtonPressed(sender: UIButton) {
        firstTabSelected()
        
        self.myPageViewController?.scrollToViewController(index: 0)
    }
    
    @IBAction func secondButtonPressed(sender: UIButton) {
        
        secondTabSelected()
        
        self.myPageViewController?.scrollToViewController(index: 1)
    }
    
    func menuButtonPressed(){
        scrollView.contentOffset.x == 0  ? closeMenu() : openMenu()
    }
    
    @IBAction func menuButtonPressed(sender: UIButton) {
        NSNotificationCenter.defaultCenter().postNotificationName("menuButtonPressed", object: nil)
    }
    
    // Change Tab color when is selected
    
    func firstTabSelected(){
        firstButton.backgroundColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.5)
        secondButton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
    }
    
    func secondTabSelected(){
        secondButton.backgroundColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.5)
        firstButton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
    }
    
    
    // This wrapper function is necessary because
    // closeMenu params do not match up with Notification
    func closeMenuViaNotification(){
        closeMenu()
    }
    
    // Use scrollview content offset-x to slide the menu.
    func closeMenu(animated:Bool = true){
        scrollView.setContentOffset(CGPoint(x: leftMenuWidth, y: 0), animated: animated)
    }
    
    // Open is the natural state of the menu because of how the storyboard is setup.
    func openMenu(){
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    // see http://stackoverflow.com/questions/25666269/ios8-swift-how-to-detect-orientation-change
    // close the menu when rotating to landscape.
    // Note: you have to put this on the main queue in order for it to work
    func rotated(){
        if UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) {
            dispatch_async(dispatch_get_main_queue()) {
                self.closeMenu()
            }
        }
    }
    
}

extension MainWindow : UIScrollViewDelegate {
    
    // http://www.4byte.cn/question/49110/uiscrollview-change-contentoffset-when-change-frame.html
    // When paging is enabled on a Scroll View, 
    // a private method _adjustContentOffsetIfNecessary gets called,
    // presumably when present whatever controller is called.
    // The idea is to disable paging.
    // But we rely on paging to snap the slideout menu in place
    // (if you're relying on the built-in pan gesture).
    // So the approach is to keep paging disabled.  
    // But enable it at the last minute during scrollViewWillBeginDragging.
    // And then turn it off once the scroll view stops moving.
    // 
    // Approaches that don't work:
    // 1. automaticallyAdjustsScrollViewInsets -- don't bother
    // 2. overriding _adjustContentOffsetIfNecessary -- messing with private methods is a bad idea
    // 3. disable paging altogether.  works, but at the loss of a feature
    // 4. nest the scrollview inside UIView, so UIKit doesn't mess with it.  may have worked before,
    //    but not anymore.
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollView.pagingEnabled = true
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollView.pagingEnabled = false
    }
}

extension MainWindow: MyPageViewControllerDelegate {
    
    // Change Tab color when is selected with slider movement
    func selectedTab(myPageViewController: MyPageViewController,
        didUpdatePageIndex index: Int){
    
            if index == 0 {
                firstTabSelected()
            } else if index == 1 {
                secondTabSelected()
            }
    }
}
