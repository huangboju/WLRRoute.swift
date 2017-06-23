//
//  MGJRouter.swift
//  WLRRoute.swift
//
//  Created by 伯驹 黄 on 2017/2/28.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

/**
 *  routerParameters 里内置的几个参数会用到上面定义的 string
 */
typealias MGJRouterHandler = ([String: Any]) -> Void

/**
 *  需要返回一个 object，配合 objectForURL: 使用
 */
typealias MGJRouterObjectHandler = ([String: Any]) -> Any
typealias MGJRouterCompletionHandle = (Any?) -> Void

let MGJRouterParameterCompletion = "MGJRouterParameterCompletion"
let MGJRouterParameterUserInfo = "MGJRouterParameterUserInfo"

class MGJRouter {

    private var routes = NSMutableDictionary()
    let MGJ_ROUTER_WILDCARD_CHARACTER = "~"
    static let specialCharacters = "/?&."
    let MGJRouterParameterURL = "MGJRouterParameterURL"

    static let shared = MGJRouter()

    /**
     *  注册 URLPattern 对应的 Handler，在 handler 中可以初始化 VC，然后对 VC 做各种操作
     *
     *  @param URLPattern 带上 scheme，如 mgj://beauty/:id
     *  @param handler    该 block 会传一个字典，包含了注册的 URL 中对应的变量。
     *                    假如注册的 URL 为 mgj://beauty/:id 那么，就会传一个 @{@"id": 4} 这样的字典过来
     */
    static func register(_ URLPattern: String, to handler: MGJRouterHandler?) {
        shared.add(URLPattern, and: handler)
    }

    /**
     *  取消注册某个 URL Pattern
     *
     *  @param URLPattern
     */
    static func deregister(URLPattern: String) {
        shared.remove(URLPattern)
    }

    /**
     *  打开此 URL
     *  会在已注册的 URL -> Handler 中寻找，如果找到，则执行 Handler
     *
     *  @param URL 带 Scheme，如 mgj://beauty/3
     */
    static func open(_ URL: String) {
        open(URL, completion: nil)
    }

    /**
     *  打开此 URL，同时当操作完成时，执行额外的代码
     *
     *  @param URL        带 Scheme 的 URL，如 mgj://beauty/4
     *  @param completion URL 处理完成后的 callback，完成的判定跟具体的业务相关
     */
    static func open(_ URL: String, completion: ((Any) -> Void)?) {
        open(URL, with: nil, completion: completion)
    }

    /**
     *  打开此 URL，带上附加信息，同时当操作完成时，执行额外的代码
     *
     *  @param URL        带 Scheme 的 URL，如 mgj://beauty/4
     *  @param parameters 附加参数
     *  @param completion URL 处理完成后的 callback，完成的判定跟具体的业务相关
     */
    static func open(_ URL: String, with userInfo: [String: Any]?, completion: MGJRouterCompletionHandle?) {
        guard let parameters = shared.extractParameters(from: URL.encoding) else { return }
        var para = parameters
        for (key, value) in parameters {
            guard let str = value as? String else { continue }
            para[key] = str.decoding
        }

        if let completion = completion {
            para[MGJRouterParameterCompletion] = completion
        }
        if let userInfo = userInfo {
            para[MGJRouterParameterUserInfo] = userInfo
        }

        if let handler = para["block"] as? MGJRouterHandler {
            para.removeValue(forKey: "block")
            handler(para)
        }
    }

    /**
     *  是否可以打开URL
     *
     *  @param URL
     *
     *  @return
     */
    static func canOpen(URL: String) -> Bool {
        return shared.extractParameters(from: URL) != nil
    }

    /**
     *  注册 URLPattern 对应的 ObjectHandler，需要返回一个 object 给调用方
     *
     *  @param URLPattern 带上 scheme，如 mgj://beauty/:id
     *  @param handler    该 block 会传一个字典，包含了注册的 URL 中对应的变量。
     *                    假如注册的 URL 为 mgj://beauty/:id 那么，就会传一个 @{@"id": 4} 这样的字典过来
     *                    自带的 key 为 @"url" 和 @"completion" (如果有的话)
     */
    static func register(URLPattern: String, toObject handler: MGJRouterObjectHandler?) {
        shared.add(URLPattern, andObject: handler)
    }

    /**
     * 查找谁对某个 URL 感兴趣，如果有的话，返回一个 object
     *
     *  @param URL
     */
    static func object(for URL: String) -> Any? {
        return object(for: URL, with: nil)
    }

    /**
     * 查找谁对某个 URL 感兴趣，如果有的话，返回一个 object
     *
     *  @param URL
     *  @param userInfo
     */
    static func object(for URL: String, with userInfo: [String: Any]?) -> Any? {
        let router = MGJRouter.shared
        var parameters = router.extractParameters(from: URL.encoding)

        guard let hander = parameters?["block"] as? MGJRouterObjectHandler else { return nil }
        if let userInfo = userInfo {
            parameters?[MGJRouterParameterUserInfo] = userInfo
        }

        _ = parameters?.removeValue(forKey: "block")
        return hander(parameters!)
    }

    /**
     *  调用此方法来拼接 urlpattern 和 parameters
     *
     *  #define MGJ_ROUTE_BEAUTY @"beauty/:id"
     *  [MGJRouter generateURLWithPattern:MGJ_ROUTE_BEAUTY, @[@13]];
     *
     *
     *  @param pattern    url pattern 比如 @"beauty/:id"
     *  @param parameters 一个数组，数量要跟 pattern 里的变量一致
     *
     *  @return
     */
    static func generateURL(with pattern: String, parameters: [String]) -> String {
        var startIndexOfColon = 0
        var placeholders: [String] = []

        for i in 0 ..< pattern.length {

            let character = pattern[i]
            if character == ":" {
                startIndexOfColon = i
            }

            if specialCharacters.contains(character) && i > (startIndexOfColon + 1) && startIndexOfColon > 1 {
                let range = NSRange(location: startIndexOfColon, length: i - startIndexOfColon)

                let placeholder = pattern.substr(with: range)

                if !checkIfContainsSpecialCharacter(placeholder) {
                    placeholders.append(placeholder)
                    startIndexOfColon = 0
                }
            }
            if i == pattern.length - 1 && startIndexOfColon > 1 {
                let range = NSRange(location: startIndexOfColon, length: i - startIndexOfColon + 1)
                let placeholder = pattern.substr(with: range)

                if !checkIfContainsSpecialCharacter(placeholder) {
                    placeholders.append(placeholder)
                }
            }
        }

        var parsedResult = pattern

        for (i, placeholder) in placeholders.enumerated() {
            let idx = parameters.count > i ? i : parameters.count - 1
            parsedResult = pattern.replacingOccurrences(of: placeholder, with: parameters[idx])
        }

        return parsedResult
    }

    func add(_ URLPattern: String, and handler: MGJRouterHandler?) {
        let subRoutes = add(URLPattern)
        if let handler = handler {
            subRoutes["_"] = handler
        }
    }

    func add(_ URLPattern: String, andObject handler: MGJRouterObjectHandler?) {
        let subRoutes = add(URLPattern)
        if let handler = handler {
            subRoutes["_"] = handler
        }
    }

    func add(_ URLPattern: String) -> NSMutableDictionary {
        let components = pathComponents(from: URLPattern)

        var subRoutes = routes

        for pathComponent in components {
            if subRoutes[pathComponent] == nil {
                subRoutes[pathComponent] = NSMutableDictionary()
            }
            subRoutes = subRoutes[pathComponent] as! NSMutableDictionary
        }
        return subRoutes
    }

    // MARK: - Utils

    func extractParameters(from url: String) -> [String: Any]? {
        var parameters: [String: Any] = [MGJRouterParameterURL: url]
        var subRoutes = routes
        let components = pathComponents(from: url)

        var found = false

        for pathComponent in components {

            // 对 key 进行排序，这样可以把 ~ 放到最后
            let subRoutesKeys = (subRoutes.allKeys as! [String]).sorted(by: <)

            for key in subRoutesKeys {
                if key == pathComponent || key == MGJ_ROUTER_WILDCARD_CHARACTER {
                    found = true
                    subRoutes = subRoutes[key] as! NSMutableDictionary
                    break
                } else if key.hasPrefix(":") {
                    found = true
                    subRoutes = subRoutes[key] as! NSMutableDictionary

                    var newKey = key.substring(from: 1)
                    var newPathComponent = pathComponent
                    // 再做一下特殊处理，比如 :id.html -> :id

                    if type(of: self).checkIfContainsSpecialCharacter(key) {

                        let specialSet = CharacterSet(charactersIn: MGJRouter.specialCharacters)

                        if let range = key.rangeOfCharacter(from: specialSet) {
                            // 把 pathComponent 后面的部分也去掉

                            newKey = newKey.substring(to: newKey.index(range.lowerBound, offsetBy: -1))

                            let suffixToStrip = key.substring(from: range.lowerBound)

                            newPathComponent = newPathComponent.replacingOccurrences(of: suffixToStrip, with: "")
                        }
                    }
                    parameters[newKey] = newPathComponent
                    break
                }
            }

            // 如果没有找到该 pathComponent 对应的 handler，则以上一层的 handler 作为 fallback
            if !found && subRoutes["_"] == nil {
                return nil
            }
        }

        // Extract Params From Query.

        if let url = URL(string: url), let queryItems = NSURLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            for item in queryItems {
                parameters[item.name] = item.value
            }
        }

        if let value = subRoutes["_"] {
            parameters["block"] = value
        }

        return parameters
    }

    func remove(_ URLPattern: String) {

        var components = pathComponents(from: URLPattern)

        // 只删除该 pattern 的最后一级
        if components.count >= 1 {
            // 假如 URLPattern 为 a/b/c, components 就是 @"a.b.c" 正好可以作为 KVC 的 key
            let key = components.joined(separator: ".")
            var route = routes.value(forKeyPath: key) as? NSMutableDictionary

            guard let count = route?.count, count >= 1 else {
                return
            }
            let lastComponent = components.popLast() ?? ""

            // 有可能是根 key，这样就是 self.routes 了
            route = routes
            if components.isEmpty { return }

            let componentsWithoutLast = components.joined(separator: ".")
            route = routes.value(forKeyPath: componentsWithoutLast) as? NSMutableDictionary
            route?.removeObject(forKey: lastComponent)
        }
    }

    func pathComponents(from url: String) -> [String] {
        var pathComponents: [String] = []

        var urlStr = ""

        if url.contains("://") {
            let pathSegments = url.components(separatedBy: "://")
            // 如果 URL 包含协议，那么把协议作为第一个元素放进去
            pathComponents.append(pathSegments[0])

            // 如果只有协议，那么放一个占位符
            urlStr = pathSegments.last ?? ""
            if urlStr.isEmpty {
                pathComponents.append(MGJ_ROUTER_WILDCARD_CHARACTER)
            }
        }

        guard let newUrl = URL(string: urlStr) else {
            return pathComponents
        }
        for pathComponent in newUrl.pathComponents where pathComponent != "/" {
            if pathComponent.substring(to: 1) == "?" {
                break
            }
            pathComponents.append(pathComponent)
        }
        return pathComponents
    }

    static func checkIfContainsSpecialCharacter(_ checkedString: String) -> Bool {
        let specialCharactersSet = CharacterSet(charactersIn: specialCharacters)
        return checkedString.rangeOfCharacter(from: specialCharactersSet) != nil
    }
}

func arrToDict(arr: [String], dict: [String: Any] = [:]) -> [String: Any] {
    guard let last = arr.last else {
        return dict
    }
    let head = Array(arr.dropLast())
    return arrToDict(arr: head, dict: [last: dict])
}
