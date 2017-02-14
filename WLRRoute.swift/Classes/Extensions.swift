//
//  Copyright © 2016年 xiAo_Ju. All rights reserved.
//

extension String {
    var encoding: String {
        let unreservedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
        let unreservedCharset = CharacterSet(charactersIn: unreservedChars)
        return addingPercentEncoding(withAllowedCharacters: unreservedCharset) ?? self
    }

    var decoding: String {
        return removingPercentEncoding ?? self
    }

    func index(from: Int) -> Index {
        return index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }

    func substring(to: Int) -> String {
        return substring(to: index(from: to))
    }

    func substr(with range: NSRange) -> String {
        let start = index(startIndex, offsetBy: range.location)
        let end = index(endIndex, offsetBy: range.location + range.length - characters.count)
        return substring(with: start ..< end)
    }

    var length: Int {
        return characters.count
    }
}

extension URL {
    var parameters: [String: String] {

        let components = NSURLComponents(url: self, resolvingAgainstBaseURL: false)

        // 取出items，如果為nil就改為預設值 空陣列
        let queryItems = components?.queryItems ?? []

        return queryItems.reduce([String: String]()) {
            var dict = $0
            dict[$1.name] = $1.value ?? ""
            return dict
        }
    }
}

extension UIViewController {

    private struct AssociatedKeys {
        static var wlr_request = "wlr_request"
    }

    var wlr_request: WLRRouteRequest? {
        set {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.wlr_request, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.wlr_request) as? WLRRouteRequest
        }
    }

    static let _onceToken = UUID().uuidString

    open override class func initialize() {
        DispatchQueue.once(token: _onceToken) {
            exchangeMethod(with: self, originalSelector: #selector(viewDidDisappear), swizzledSelector: #selector(wlr_viewDidDisappearSwzzled))
        }
    }

    func wlr_viewDidDisappearSwzzled(_ animated: Bool) {

        if let wlr_request = wlr_request, !wlr_request.isConsumed {
            wlr_request.defaultFinishTargetCallBack()
        }
        wlr_request = nil
        wlr_viewDidDisappearSwzzled(animated)
    }

    static func exchangeMethod(with cls: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
        let originalMethod = class_getInstanceMethod(cls, originalSelector)
        let swizzledMethod = class_getInstanceMethod(cls, swizzledSelector)
        /*
         如果这个类没有实现 originalSelector ，但其父类实现了，那 class_getInstanceMethod 会返回父类的方法。这样 method_exchangeImplementations 替换的是父类的那个方法，这当然不是你想要的。所以我们先尝试添加 orginalSelector ，如果已经存在，再用 method_exchangeImplementations 把原方法的实现跟新的方法实现给交换掉。
         */
        let didAddMethod = class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        if didAddMethod {
            class_replaceMethod(cls, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}

extension DispatchQueue {

    private static var _onceTracker = [String]()

    public class func once(token: String, block: () -> Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }

        if _onceTracker.contains(token) {
            return
        }
        _onceTracker.append(token)
        block()
    }
}
