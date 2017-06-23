//
//  MTRouter.swift
//
//  Created by 伯驹 黄 on 2017/3/4.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

struct MTRouter {

    public static func config(servecer: MTServecePresenter) {
        MTMatcher.shared.servecer = servecer
    }

    public static func excute(uri: String) {
        MTMatcher.match(with: uri)
    }
}
