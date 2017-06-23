//
//  WLRSignHandler.swift
//  WLRRoute.swift
//
//  Created by 伯驹 黄 on 2017/2/14.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

struct WLRSignHandler: WLRHandleable {
    func targetViewController(with _: WLRRouteRequest) -> UIViewController {
        return SecondController()
    }
}
