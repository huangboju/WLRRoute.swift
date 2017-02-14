//
//  WLRRouteRequest.swift
//  WLRRoute.swift
//
//  Created by 伯驹 黄 on 2017/2/7.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

struct WLRRouteRequest {
    let url: URL!
    let routeExpression: String?
    let queryParameters: [String: Any]!
    let routeParameters: [String: Any]?
    let primitiveParams: [String: Any]?

    var callbackURL: URL?
    var targetCallBack: ((_ error: NSError?, _ responseObject: Any?) -> Void)?
    var isConsumed = false

    func defaultFinishTargetCallBack() {
        if let targetCallBack = targetCallBack, !isConsumed {
            targetCallBack(nil, "正常执行回调")
        }
    }

    init(url: URL) {
        self.url = url
        queryParameters = url.parameters
        self.routeExpression = nil
        self.routeParameters = nil
        self.primitiveParams = nil
        self.targetCallBack = nil
    }

    init(url: URL, routeExpression: String, routeParameters: [String: Any]?, primitiveParams: [String: Any]?, targetCallBack: ((_ error: NSError?, _ responseObject: Any) -> Void)?) {
        self.url = url
        queryParameters = url.parameters
        self.routeExpression = routeExpression
        self.routeParameters = routeParameters
        self.primitiveParams = primitiveParams
        self.targetCallBack = targetCallBack
    }

    subscript(_ key: String) -> Any {
        var value = routeParameters?[key]
        if value == nil {
            value = queryParameters[key]
        }
        if value == nil {
            value = primitiveParams?[key]
        }
        return value!
    }
}
