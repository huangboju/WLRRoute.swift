//
//  WLRRouter.swift
//  WLRRoute.swift
//
//  Created by 伯驹 黄 on 2017/2/8.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

class WLRRouter {
    lazy var middlewares = NSHashTable<AnyObject>(options: NSPointerFunctions.Options.weakMemory)
    lazy var routeHandles: [String: WLRRouteHandler] = [:]
    lazy var routeMatchers: [String: WLRRouteMatcher] = [:]

    static let shared = WLRRouter()

    private init() {}

    func add(_ middleware: WLRRouteMiddleware) {
        middlewares.add(middleware)
    }

    func remove(middleware: WLRRouteMiddleware) {
        if middlewares.contains(middleware) {
            middlewares.remove(middleware)
        }
    }

    /** 
     注册一个route表达式并与一个block处理相关联

     @param routeHandlerBlock handler对象用以处理匹配route表达式的url的请求
     @param route url的路由表达式，支持正则表达式的分组，例如app://login/:phone({0,9+})是一个表达式，:phone代表该路径值对应的key,可以在WLRRouteRequest对象中的routeParameters中获取
     */
    func register(handler: WLRRouteHandler, for route: String) {
        if !route.isEmpty {
            routeMatchers[route] = WLRRouteMatcher.matcher(with: route)
            routeHandles[route] = handler
        }
    }

    /** 
     检测url是否能够被处理，不包含中间件的检查

     @param url 请求的url
     @return 是否可以handle
     */
    func canHandle(with url: URL) -> Bool {
        for route in routeMatchers.keys {
            let matcher = routeMatchers[route]
            let request = matcher?.createRequest(with: url, primitiveParameters: nil, targetCallBack: nil)
            if request != nil {
                return true
            }
        }
        return false
    }

    func set(handle: WLRRouteHandler?, for keyedSubscript: String) {
        if let handle = handle {
            register(handler: handle, for: keyedSubscript)
        } else {
            routeHandles.removeValue(forKey: keyedSubscript)
            routeMatchers.removeValue(forKey: keyedSubscript)
        }
    }

    /** 
     处理url请求

     @param URL 调用的url
     @param primitiveParameters 携带的原生对象
     @param targetCallBack 传给目标对象的回调block
     @param completionBlock 完成路由中转的block
     @return 是否能够handle
     */
    func handle(url: URL, primitiveParameters: [String: Any]?, targetCallBack: ((_ error: NSError?, _ responseObject: Any?) -> Void)?, with completionBlock: ((Bool, NSError?) -> Void)?) {
        var error: NSError?
        var isHandled = false
        var request: WLRRouteRequest?
        for route in routeMatchers.keys {
            let matcher = routeMatchers[route]
            request = matcher?.createRequest(with: url, primitiveParameters: primitiveParameters, targetCallBack: targetCallBack)
            if request != nil {
                var responseObject: [String: Any]?
                for middleware in middlewares.allObjects {
                    if let m = middleware as? WLRRouteMiddleware {
                        responseObject = m.middlewareHandleRequest(with: request!, error: &error)
                        if responseObject != nil || error != nil {
                            isHandled = true
                            if let callBack = request?.targetCallBack {
                                DispatchQueue.main.async {
                                    callBack(error, responseObject)
                                }
                            }
                            break
                        }
                    }
                }
            }
            if !isHandled {
                isHandled = handle(routeExpression: route, with: request, error: &error)
            }
        }
        if request == nil {
            error = NSError.WLRNotFoundError
        }
        completeRoute(with: isHandled, error: error, completionHandler: completionBlock)
    }

    func handle(routeExpression: String, with request: WLRRouteRequest?, error: inout NSError?) -> Bool {
        guard let handle = routeHandles[routeExpression], let request = request else { return false }
        if !handle.shouldHandle(with: request) {
            return false
        }
        return handle.handle(request: request, error: &error)
    }

    func completeRoute(with success: Bool, error: NSError?, completionHandler: ((Bool, NSError?) -> Void)?) {
        if let completionHandler = completionHandler {
            DispatchQueue.main.async {
                completionHandler(success, error)
            }
        }
    }
}
