//
//  WLRRouteHandler.swift
//  WLRRoute.swift
//
//  Created by 伯驹 黄 on 2017/2/8.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

protocol WLRHandleable {
    func shouldHandle(with request: WLRRouteRequest) -> Bool
    func targetViewController(with request: WLRRouteRequest) -> UIViewController
    func preferModalPresentation(with request: WLRRouteRequest) -> Bool
}

extension WLRHandleable {
    func shouldHandle(with _: WLRRouteRequest) -> Bool {
        return true
    }

    func preferModalPresentation(with _: WLRRouteRequest) -> Bool {
        return false
    }

    func sourceViewControllerForTransition(with _: WLRRouteRequest) -> UIViewController {
        return UIApplication.shared.keyWindow!.rootViewController!
    }

    func handle(request: WLRRouteRequest) -> Bool {
        let sourceViewController = sourceViewControllerForTransition(with: request)
        let targetViewController = self.targetViewController(with: request)

        targetViewController.wlr_request = request

        let isPreferModal = preferModalPresentation(with: request)

        return transition(with: request, sourceViewController: sourceViewController, targetViewController: targetViewController, isPreferModal: isPreferModal)
    }

    func transition(with _: WLRRouteRequest, sourceViewController: UIViewController, targetViewController: UIViewController, isPreferModal: Bool) -> Bool {
        let nav = sourceViewController as? UINavigationController
        if isPreferModal || nav == nil {
            if sourceViewController.presentedViewController == nil { // AController -> BController,在AController重载touchesBegan，会响应多次
                sourceViewController.present(targetViewController, animated: true, completion: nil)
            }
        } else if let nav = nav {
            nav.pushViewController(targetViewController, animated: true)
        }
        return true
    }
}
