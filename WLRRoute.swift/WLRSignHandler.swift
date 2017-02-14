//
//  WLRSignHandler.swift
//  WLRRoute.swift
//
//  Created by 伯驹 黄 on 2017/2/14.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

class WLRSignHandler: WLRRouteHandler {
    override func targetViewController(with request: WLRRouteRequest) -> UIViewController {
        return SecondController()
    }
}
