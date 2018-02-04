
import Foundation

public extension UINavigationController {
  
    func pushViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        pushViewController(viewController, animated: animated)
        
        if animated, let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }
    
    func popViewController(animated: Bool, completion: @escaping () -> Void) {
        popViewController(animated: animated)
        
        if animated, let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }
    
    public var rootViewControllerInNavigationStack : UIViewController? {
        return viewControllers.first 
    }
    
    public func previousViewControllerInNavigationStack() -> UIViewController? {
        guard let _ = self.navigationController else {
            return nil
        }
        
        guard let viewControllers = self.navigationController?.viewControllers else {
            return nil
        }
        
        guard viewControllers.count >= 2 else {
            return nil
        }        
        return viewControllers[viewControllers.count - 2]
    }
    
    
    func setRootViewController (_ vc : UIViewController){
        viewControllers = [vc]
    }
    
    public func popNavigationStack<T : UIViewController>(to target: T.Type, animated: Bool = true) {
        let popToTargetVC : () -> Void = {
            
            while !(self.topViewController is T) {
                self.popViewController(animated: false)
                if self.viewControllers.first == self.topViewController {
                    break
                }
            }
        }
        
        if self.topViewController?.presentedViewController != nil {
            self.topViewController?.dismiss(animated: animated, completion: {
                popToTargetVC()
            })
        } else {
            popToTargetVC()
        }
    }
    
    func unwindBack(to viewController: Swift.AnyClass, animated: Bool = false) {
        
        for element in self.viewControllers as Array {
            if element.isKind(of: viewController) {
                self.popToViewController(element, animated: animated)
                break
            }
        }
    }
    
    // Pop to specific view controller
    public func pop<T : UIViewController>(to target: T.Type, animated: Bool = true) {
        for aViewController in self.viewControllers {
            if(aViewController is T){
                self.popToViewController(aViewController, animated: animated)
                break
            }
        }
    }
    
    func pushOrPop( to viewController: UIViewController){
        
        if self.viewControllers.contains(viewController) {
            let fullType = type(of: viewController)
            print("view controller \(fullType), is in the navigation stack. \(self.viewControllers)")
            //self.unwindBack(to: fullType, animated: true)
            self.pop(to: fullType, animated: true)
        }else {
            self.pushViewController(viewController, animated: true)
        }
    }
}
