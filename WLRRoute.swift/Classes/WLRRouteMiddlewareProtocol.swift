//
//  WLRRouteMiddlewareProtocol.swift
//  WLRRoute.swift
//
//  Created by 伯驹 黄 on 2017/2/7.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

protocol WLRRouteMiddleware: AnyObject {
    func middlewareHandleRequest(with primitiveRequest: WLRRouteRequest, error: inout NSError?) -> [String: Any]?
}
