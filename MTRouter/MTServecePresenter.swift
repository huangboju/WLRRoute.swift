//
//  MTWebServece.swift
//  WLRRoute.swift
//
//  Created by 伯驹 黄 on 2017/3/4.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

// 给用户自己实现
public protocol MTServecePresenter {
    func pushController(with url: URL)

    func selectTab(with url: URL)

    func openWebView(with url: URL)

    func showAlert(with url: URL)

    func otherService(with url: URL)

    func openScheme(with url: URL)
}

// MARK: - iOS URL Scheme
extension MTServecePresenter {
    func openScheme(with _: URL) {
    }

    // MARK: - 界面切换
    func pushController(with _: URL) {
    }

    // MARK: - tab切换
    func selectTab(with _: URL) {
    }

    // MARK: - 打开网页
    func openWebView(with _: URL) {
        print("请实现打开网页服务")
    }

    // MARK: - 弹窗
    func showAlert(with _: URL) {
        print("请实现弹出服务")
    }

    // MARK: - 其他
    func otherService(with _: URL) {
        print("请实现其他服务")
    }
}

struct MTServecer: MTServecePresenter {}

extension UIApplication {
    public static var visibleViewController: UIViewController? {
        return UIApplication.getVisibleViewController(from: UIApplication.shared.keyWindow?.rootViewController)
    }

    public static func getVisibleViewController(from vc: UIViewController?) -> UIViewController? {

        if let nav = vc as? UINavigationController {
            return getVisibleViewController(from: nav.visibleViewController)
        } else if let tab = vc as? UITabBarController {
            return getVisibleViewController(from: tab.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return getVisibleViewController(from: pvc)
            } else {
                return vc
            }
        }
    }
}
