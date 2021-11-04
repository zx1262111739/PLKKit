//
//  PLNavigationController.swift
//  PLKit
//
//  Created by Plumk on 2020/5/8.
//  Copyright © 2020 Plumk. All rights reserved.
//

import UIKit


// MARK: - Class PLNavigationController
open class PLNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    public typealias TransitionCompleteCallback = () -> Void
    
    // push/pop 完成回调
    var transitionCompleteCallback: TransitionCompleteCallback?
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
    }
    
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // 从xib 过来的需要重置一下
        self.setViewControllers(self.viewControllers, animated: false)
    }

    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.setNavigationBarHidden(true, animated: false)
    }
    
    /// 重新设置手势代理
    fileprivate func resetInteractivePopGestureRecognizer() {
        
        guard self.viewControllers.count > 1,
              let vc = self.viewControllers.last as? PLNavigationContainerViewController else {
                  
            self.interactivePopGestureRecognizer?.delegate = nil
            self.interactivePopGestureRecognizer?.isEnabled = false
            return
        }
        
        self.interactivePopGestureRecognizer?.delegate = vc
        self.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    open override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers.map({
            
            if let container = $0 as? PLNavigationContainerViewController {
                if container.isPushed {
                    return container
                }
            }
            
            let vc = PLNavigationContainerViewController.init(content: $0)
            vc.isPushed = true
            return vc
        }), animated: animated)
    }
    
    // MARK: - PUSH And POP
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if viewController != self.viewControllers.last && viewController.navigationController == nil {
        
            /*
             animated 为true的时候
             可能同一个viewController 会走2次这个方法
             */
            if let container = viewController as? PLNavigationContainerViewController, container.isPushed {
                return super.pushViewController(container, animated: animated)
            }
            
            let container = PLNavigationContainerViewController.init(content: viewController)
            container.isPushed = true
            super.pushViewController(container, animated: animated)
        }
    }
    
    // MARK: - UINavigationControllerDelegate
    open func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        self.resetInteractivePopGestureRecognizer()
        
        self.transitionCompleteCallback?()
        self.transitionCompleteCallback = nil
    }
    
    // MARK: - Child
    open override var childForStatusBarStyle: UIViewController? {
        return self.visibleViewController
    }
    
    open override var childForStatusBarHidden: UIViewController? {
        return self.visibleViewController
    }
    
    open override var childForHomeIndicatorAutoHidden: UIViewController? {
        return self.visibleViewController
    }
    
    open override var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        return self.visibleViewController
    }
    
    open override var prefersStatusBarHidden: Bool {
        return self.visibleViewController?.prefersStatusBarHidden ?? false
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.visibleViewController?.preferredStatusBarStyle ?? .default
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return self.visibleViewController?.preferredStatusBarUpdateAnimation ?? .fade
    }
    
    open override var shouldAutorotate: Bool {
        return self.visibleViewController?.shouldAutorotate ?? false
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return self.visibleViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.visibleViewController?.supportedInterfaceOrientations ?? .portrait
    }
}





// MARK: - Extension UIViewController.PL.navigationController
extension PL where Base: UIViewController {

    /*
     这里取到是根部NavigationController 与 self.navigationController 不一样
     通过 self.navigationController 调用 viewControllers 得到的viewController 都是unpack之后的
     通过该属性调用得到的viewController 都是 ContainerController
     topViewController 和 visiableViewController 使用pl_开头的属性
     */
    public var navigationController: PLNavigationController? {
        if let nav = self.base as? PLNavigationController {
            return nav
        }
        
        if let nav = self.base.navigationController as? PLNavigationController {
            return nav
        }
        
        return self.base.navigationController?.navigationController as? PLNavigationController
    }

    public var navigationBar: PLNavigationContainerBar? {
        if let container = self.base.navigationController?.parent as? PLNavigationContainerViewController {
            return container.containerBar
        }

        if let container = self.base as? PLNavigationContainerViewController {
            return container.containerBar
        }

        return nil
    }
}
