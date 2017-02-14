//
//  WLRRouteHandler.swift
//  WLRRoute.swift
//
//  Created by 伯驹 黄 on 2017/2/8.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

class WLRRouteHandler {
    func shouldHandle(with request: WLRRouteRequest) -> Bool {
        return true
    }

    func targetViewController(with request: WLRRouteRequest) -> UIViewController {

        return UIViewController()
    }

    func sourceViewControllerForTransition(with request: WLRRouteRequest) -> UIViewController {
        return UIApplication.shared.keyWindow!.rootViewController!
    }

    func handle(request: WLRRouteRequest, error: inout NSError?) -> Bool {
        let sourceViewController = sourceViewControllerForTransition(with: request)
        let targetViewController = self.targetViewController(with: request)

        if !(sourceViewController.isKind(of: UIViewController.self)) || !(targetViewController.isKind(of: UIViewController.self)) {
            error = NSError.WLRTransitionError
            return false
        }
        targetViewController.wlr_request = request

        let isPreferModal = preferModalPresentation(with: request)

        return transition(with: request, sourceViewController: sourceViewController, targetViewController: targetViewController, isPreferModal: isPreferModal, error: error)
    }

    func transition(with request: WLRRouteRequest, sourceViewController: UIViewController, targetViewController: UIViewController, isPreferModal: Bool, error: NSError?) -> Bool {
        let nav = sourceViewController as? UINavigationController
        if isPreferModal || nav == nil {
            sourceViewController.present(targetViewController, animated: true, completion: nil)
        } else if let nav = nav {
            nav.pushViewController(targetViewController, animated: true)
        }
        return true
    }

    func preferModalPresentation(with request: WLRRouteRequest) -> Bool {
        return false
    }
}
