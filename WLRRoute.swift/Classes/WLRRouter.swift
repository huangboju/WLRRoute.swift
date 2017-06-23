//
//  WLRRouter.swift
//  WLRRoute.swift
//
//  Created by 伯驹 黄 on 2017/2/8.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

class WLRRouter {
    lazy var routeHandles: [String: WLRHandleable] = [:]
    lazy var routeMatchers: [String: WLRRouteMatcher] = [:]

    static let shared = WLRRouter()

    private init() {}

    // 注册正则列表
    static func register(matchers: [String]) {
        matchers.forEach {
            shared.routeMatchers[$0] = WLRRouteMatcher.matcher(with: $0)
        }
    }

    // 注册需要特殊回调
    static func register(handle _: WLRHandleable, for matcher: String) {
        shared.routeMatchers[matcher] = WLRRouteMatcher.matcher(with: matcher)
    }

    /**
     检测url是否能够被处理，不包含中间件的检查

     @param url 请求的url
     @return 是否可以handle
     */
    static func canHandle(with url: URL) -> Bool {
        for route in shared.routeMatchers.keys {
            let matcher = shared.routeMatchers[route]
            let request = matcher?.createRequest(with: url, primitiveParameters: nil, targetCallBack: nil)
            if request != nil {
                return true
            }
        }
        return false
    }

    static func handle(urlStr: String, primitiveParameters: [String: Any]?, targetCallBack: ((_ error: NSError?, _ responseObject: Any?) -> Void)?, with completionBlock: ((Bool) -> Void)?) {
        guard let url = URL(string: urlStr) else { return }
        var error: NSError?
        var isHandled = false
        var request: WLRRouteRequest?
        for route in shared.routeMatchers.keys {
            let matcher = shared.routeMatchers[route]
            request = matcher?.createRequest(with: url, primitiveParameters: primitiveParameters, targetCallBack: targetCallBack)
            if request != nil {
                if error != nil {
                    isHandled = true
                    guard let callBack = request?.targetCallBack else { continue }
                    DispatchQueue.main.async {
                        callBack(error, nil)
                    }
                    break
                }
            }
            if !isHandled {
                isHandled = shared.handle(routeExpression: route, with: request)
            }
        }
        if request == nil {
            error = NSError.WLRNotFoundError
        }
        shared.completeRoute(with: isHandled, completionHandler: completionBlock)
    }

    func handle(routeExpression: String, with request: WLRRouteRequest?) -> Bool {
        guard let handle = routeHandles[routeExpression], let request = request else { return false }
        if !handle.shouldHandle(with: request) {
            return false
        }
        return handle.handle(request: request)
    }

    func completeRoute(with success: Bool, completionHandler: ((Bool) -> Void)?) {
        guard let completionHandler = completionHandler else { return }
        DispatchQueue.main.async {
            completionHandler(success)
        }
    }
}
