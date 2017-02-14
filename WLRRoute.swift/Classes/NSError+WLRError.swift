//
//  NSError+WLRError.swift
//  WLRRoute.swift
//
//  Created by 伯驹 黄 on 2017/2/8.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

enum WLRErrorType: Int {
    
    /** The passed URL does not match a registered route. */
    case notFound = 45150
    
    /** The matched route handler does not specify a target view controller. */
    case handlerTargetOrSourceViewControllerNotSpecified = 45151
    case blockHandleNoReturnRequest = 45152
    case middlewareRaiseError = 45153
}

extension NSError {
    static var WLRNotFoundError: NSError {
        return WLRError(with: WLRErrorType.notFound.rawValue, msg: "The passed URL does not match a registered route.")
    }
    
    static var WLRTransitionError: NSError {
        return WLRError(with: WLRErrorType.handlerTargetOrSourceViewControllerNotSpecified.rawValue, msg: "TargetViewController or SourceViewController not correct")
    }
    
    static var WLRHandleBlockNoTeturnRequest: NSError {
        return WLRError(with: WLRErrorType.blockHandleNoReturnRequest.rawValue, msg: "Block handle no turn WLRRouteRequest object")
    }

    static func WLRMiddlewareRaiseError(with msg: String) -> NSError {
        return WLRError(with: WLRErrorType.middlewareRaiseError.rawValue, msg: "WLRRouteMiddle raise a error:\(msg)")
    }

    static func WLRError(with code: NSInteger, msg: String) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString(msg, comment: "")]
        return NSError(domain: "com.wlrroute.error", code: code, userInfo: userInfo)
    }
}
