//
//  TrieRouter.swift
//  WLRRoute.swift
//
//  Created by 伯驹 黄 on 2017/2/28.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

/**
 *  routerParameters 里内置的几个参数会用到上面定义的 string
 */
typealias TrieRouterHandler = ([String: Any]) -> Void

/**
 *  需要返回一个 object，配合 objectForURL: 使用
 */
typealias TrieRouterObjectHandler = ([String: Any]) -> Any
typealias TrieRouterCompletionHandle = (Any?) -> Void

let TrieRouterParameterCompletion = "TrieRouterParameterCompletion"
let TrieRouterParameterUserInfo = "TrieRouterParameterUserInfo"

class TrieRouter {

    private var routes: Trie<String>?
    private lazy var handlers: [String: TrieRouterHandler] = [:]
    private lazy var objectHandlers: [String: TrieRouterObjectHandler] = [:]
    let Trie_ROUTER_WILDCARD_CHARACTER = "~"
    static let specialCharacters = "/?&."
    let TrieRouterParameterURL = "TrieRouterParameterURL"

    static let shared = TrieRouter()

    /**
     *  注册 URLPattern 对应的 Handler，在 handler 中可以初始化 VC，然后对 VC 做各种操作
     *
     *  @param URLPattern 带上 scheme，如 Trie://beauty/:id
     *  @param handler    该 block 会传一个字典，包含了注册的 URL 中对应的变量。
     *                    假如注册的 URL 为 Trie://beauty/:id 那么，就会传一个 @{@"id": 4} 这样的字典过来
     */
    static func register(_ URLPattern: String, to handler: TrieRouterHandler?) {
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
     *  @param URL 带 Scheme，如 Trie://beauty/3
     */
    static func open(_ URL: String) {
        open(URL, completion: nil)
    }

    /**
     *  打开此 URL，同时当操作完成时，执行额外的代码
     *
     *  @param URL        带 Scheme 的 URL，如 Trie://beauty/4
     *  @param completion URL 处理完成后的 callback，完成的判定跟具体的业务相关
     */
    static func open(_ URL: String, completion: ((Any) -> Void)?) {
        open(URL, with: nil, completion: completion)
    }

    /**
     *  打开此 URL，带上附加信息，同时当操作完成时，执行额外的代码
     *
     *  @param URL        带 Scheme 的 URL，如 Trie://beauty/4
     *  @param parameters 附加参数
     *  @param completion URL 处理完成后的 callback，完成的判定跟具体的业务相关
     */
    static func open(_ URL: String, with userInfo: [String: Any]?, completion: TrieRouterCompletionHandle?) {
        guard let parameters = shared.extractParameters(from: URL.encoding) else { return }
        var para = parameters
        for (key, value) in parameters {
            guard let str = value as? String else { continue }
            para[key] = str.decoding
        }

        if let completion = completion {
            para[TrieRouterParameterCompletion] = completion
        }
        if let userInfo = userInfo {
            para[TrieRouterParameterUserInfo] = userInfo
        }

        if let handler = para["block"] as? TrieRouterHandler {
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
     *  @param URLPattern 带上 scheme，如 Trie://beauty/:id
     *  @param handler    该 block 会传一个字典，包含了注册的 URL 中对应的变量。
     *                    假如注册的 URL 为 Trie://beauty/:id 那么，就会传一个 @{@"id": 4} 这样的字典过来
     *                    自带的 key 为 @"url" 和 @"completion" (如果有的话)
     */
    static func register(URLPattern: String, toObject handler: TrieRouterObjectHandler?) {
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
        let router = TrieRouter.shared
        var parameters = router.extractParameters(from: URL.encoding)

        guard let hander = parameters?["block"] as? TrieRouterObjectHandler else { return nil }
        if let userInfo = userInfo {
            parameters?[TrieRouterParameterUserInfo] = userInfo
        }

        _ = parameters?.removeValue(forKey: "block")
        return hander(parameters!)
    }

    /**
     *  调用此方法来拼接 urlpattern 和 parameters
     *
     *  #define Trie_ROUTE_BEAUTY @"beauty/:id"
     *  [TrieRouter generateURLWithPattern:Trie_ROUTE_BEAUTY, @[@13]];
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

    func add(_ URLPattern: String, and handler: TrieRouterHandler?) {
        add(URLPattern)
        if let handler = handler {
            handlers[URLPattern] = handler
        }
    }

    func add(_ URLPattern: String, andObject handler: TrieRouterObjectHandler?) {
        add(URLPattern)
        if let handler = handler {
            objectHandlers[URLPattern] = handler
        }
    }

    func add(_ URLPattern: String) {
        routes = Trie<String>.build(urlStr: URLPattern, emptyTrie: routes)
    }

    // MARK: - Utils

    func extractParameters(from url: String) -> [String: Any]? {
        var parameters: [String: Any] = [TrieRouterParameterURL: url]

        if !url.complete(knownWords: routes!) {
            return nil
        }

        // Extract Params From Query.

        if let url = URL(string: url), let queryItems = NSURLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            for item in queryItems {
                parameters[item.name] = item.value
            }
        }

        if let handler = handlers[url] {
            parameters["block"] = handler
        } else if let objectHandler = objectHandlers[url] {
            parameters["block"] = objectHandler
        }

        return parameters
    }

    func remove(_: String) {
    }

    static func checkIfContainsSpecialCharacter(_ checkedString: String) -> Bool {
        let specialCharactersSet = CharacterSet(charactersIn: specialCharacters)
        return checkedString.rangeOfCharacter(from: specialCharactersSet) != nil
    }
}
