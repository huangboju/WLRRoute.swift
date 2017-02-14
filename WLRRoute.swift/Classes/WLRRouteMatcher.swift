//
//  WLRRouteMatcher.swift
//  WLRRoute.swift
//
//  Created by 伯驹 黄 on 2017/2/8.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

class WLRRouteMatcher {
    var routeExpressionPattern: String?
    var originalRouteExpression: String?

    private var scheme = ""
    private var regexMatcher: WLRRegularExpression?

    static func matcher(with routeExpression: String) -> WLRRouteMatcher {
        return WLRRouteMatcher(expression: routeExpression)
    }

    init(expression: String) {
        if expression.isEmpty { return }
        let parts = expression.components(separatedBy: "://")
        scheme = parts.first ?? ""
        routeExpressionPattern = parts.last
        if let routeExpressionPattern = routeExpressionPattern {
            regexMatcher = WLRRegularExpression.expression(with: routeExpressionPattern)
        }
        originalRouteExpression = routeExpressionPattern
    }

    func createRequest(with url: URL, primitiveParameters: [String: Any]?, targetCallBack: ((_ error: NSError?, _ responseObject: Any) -> Void)?) -> WLRRouteRequest? {
        let urlString = (url.host ?? "") + url.path
        if scheme.isEmpty && scheme != url.scheme {
            return nil
        }

        let result = regexMatcher?.matchResult(for: urlString)
        if !(result?.match)! {
            return nil
        }
        return WLRRouteRequest(url: url, routeExpression: routeExpressionPattern!, routeParameters: result?.paramProperties, primitiveParams: primitiveParameters, targetCallBack: targetCallBack)
    }
}
