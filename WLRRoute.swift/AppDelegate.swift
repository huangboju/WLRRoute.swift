//
//  AppDelegate.swift
//  WLRRoute.swift
//
//  Created by 伯驹 黄 on 2017/2/7.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        WLRRouter.register(matchers: ["/signin/:phone([0-9]+)"])

        TrieRouter.register("mgj://foo/bar") { _ in
        }

        TrieRouter.open("mgj://foo/bar")

        DispatchQueue.global().async {
            self.load()
        }

        return true
    }

    func load() {
        let detailViewController = MGJDetailController()

        MGJViewController.register(with: "基本使用") { () -> UIViewController in
            detailViewController.selectedSelector = #selector(MGJDetailController.demoBasicUsage)
            return detailViewController
        }

        MGJViewController.register(with: "中文匹配") { () -> UIViewController in
            detailViewController.selectedSelector = #selector(MGJDetailController.demoChineseCharacter)
            return detailViewController
        }

        MGJViewController.register(with: "自定义参数") { () -> UIViewController in
            detailViewController.selectedSelector = #selector(MGJDetailController.demoParameters)
            return detailViewController
        }

        MGJViewController.register(with: "传入字典信息") { () -> UIViewController in
            detailViewController.selectedSelector = #selector(MGJDetailController.demoUserInfo)
            return detailViewController
        }

        MGJViewController.register(with: "Fallback 到全局的 URL Pattern") { () -> UIViewController in
            detailViewController.selectedSelector = #selector(MGJDetailController.demoFallback)
            return detailViewController
        }

        MGJViewController.register(with: "Open 结束后执行 Completion Block") { () -> UIViewController in
            detailViewController.selectedSelector = #selector(MGJDetailController.demoCompletion)
            return detailViewController
        }

        MGJViewController.register(with: "基于 URL 模板生成 具体的 URL") { () -> UIViewController in
            detailViewController.selectedSelector = #selector(MGJDetailController.demoGenerateURL)
            return detailViewController
        }

        MGJViewController.register(with: "取消注册 URL Pattern") { () -> UIViewController in
            detailViewController.selectedSelector = #selector(MGJDetailController.demoDeregisterURLPattern)
            return detailViewController
        }

        MGJViewController.register(with: "同步获取 URL 对应的 Object") { () -> UIViewController in
            detailViewController.selectedSelector = #selector(MGJDetailController.demoObjectForURL)
            return detailViewController
        }
    }
}
