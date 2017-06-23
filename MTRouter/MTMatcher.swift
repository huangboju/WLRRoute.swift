//
//  MTMatcherFactory.swift
//  WLRRoute.swift
//
//  Created by 伯驹 黄 on 2017/3/4.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

protocol MatcherPresenter {
    init(uri: URL)
}

enum MTMatcherType: String {
    case page // 界面跳转
    case alert // 弹窗
    case tab // tab切换
    case scheme // iOS URL Scheme
}

final class MTMatcher {

    static let shared = MTMatcher()

    var servecer: MTServecePresenter
    var components: NSURLComponents?

    private init() {
        servecer = MTServecer()
    }

    static func match(with uri: String) {
        // 在这里容错处理

        let dataDetector = try? NSDataDetector(types:
            NSTextCheckingTypes(NSTextCheckingResult.CheckingType.link.rawValue))
        // 匹配字符串，返回结果集
        let results = dataDetector?.matches(in: uri, options: [], range: NSRange(location: 0, length: uri.length))
        guard let url = results?.first?.url else {
            print("❌❌❌ 链接不合法")
            return
        }

        if UIApplication.shared.canOpenURL(url) {
            shared.servecer.openWebView(with: url)
            return
        }

        shared.components = NSURLComponents(url: url, resolvingAgainstBaseURL: false)

        shared.selectMatcher(with: MTMatcherType(rawValue: shared.components?.host ?? ""), for: url)
    }

    //  NSURLComponents在这里分割掉

    private func selectMatcher(with type: MTMatcherType?, for uri: URL) {
        guard let type = type else {
            servecer.otherService(with: uri)
            return
        }
        switch type {
        case .page:
            servecer.pushController(with: uri)
        case .alert:
            servecer.showAlert(with: uri)
        case .tab:
            servecer.selectTab(with: uri)
        case .scheme:
            servecer.openScheme(with: uri)
        }
    }
}
