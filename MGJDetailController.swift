//
//  ViewController.swift
//  WLRRoute.swift
//
//  Created by 伯驹 黄 on 2017/3/2.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import UIKit

class MGJDetailController: UIViewController {

    var selectedSelector: Selector?

    private lazy var resultTextView: UITextView = {
        let padding: CGFloat = 20
        let viewWith = self.view.frame.width
        let viewHeight = self.view.frame.height - 64
        let resultTextView = UITextView(frame: CGRect(x: padding, y: padding + 64, width: viewWith - padding * 2, height: viewHeight - padding * 2))
        resultTextView.layer.borderColor = UIColor(white: 0.8, alpha: 1).cgColor
        resultTextView.layer.borderWidth = 1
        resultTextView.isEditable = false
        resultTextView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0)
        resultTextView.font = UIFont.systemFont(ofSize: 14)
        resultTextView.textColor = UIColor(white: 0.2, alpha: 1)
        resultTextView.contentOffset = .zero
        return resultTextView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 239 / 255, green: 239 / 255, blue: 244 / 255, alpha: 1)
        view.addSubview(resultTextView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resultTextView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        guard let selectedSelector = selectedSelector else {
            return
        }
        perform(selectedSelector, with: nil, afterDelay: 0)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        resultTextView.removeObserver(self, forKeyPath: "contentSize")
        resultTextView.text = ""
    }

    func append(log: String) {
        var currentLog = resultTextView.text ?? ""
        if currentLog.isEmpty {
            currentLog = log
        } else {
            currentLog += "\n----------\n\(log)"
        }
        resultTextView.text = currentLog
        resultTextView.sizeThatFits(CGSize(width: view.frame.width, height: CGFloat.infinity))
    }

    // MARK: - Demos
    func demoFallback() {
        MGJRouter.register("mgj://") { dict in
            self.append(log: "匹配到了 url，以下是相关信息")
            self.append(log: "routerParameters:\(dict)")
        }

        MGJRouter.register("mgj://foo/bar/none/exists") { _ in
            self.append(log: "it should be triggered")
        }

        MGJRouter.open("mgj://foo/bar")
    }

    func demoBasicUsage() {
        MGJRouter.register("mgj://foo/bar") { dict in
            self.append(log: "匹配到了 url，以下是相关信息")
            self.append(log: "routerParameters:\(dict)")
        }

        MGJRouter.open("mgj://foo/bar")
    }

    func demoChineseCharacter() {
        MGJRouter.register("mgj://category/家居") { dict in
            self.append(log: "匹配到了 url，以下是相关信息")
            self.append(log: "routerParameters:\(dict)")
        }

        MGJRouter.open("mgj://category/家居")
    }

    func demoUserInfo() {
        MGJRouter.register("mgj://category/travel") { dict in
            self.append(log: "匹配到了 url，以下是相关信息")
            self.append(log: "routerParameters:\(dict)")
        }

        MGJRouter.open("mgj://category/travel", with: ["user_id": 1900], completion: nil)
    }

    func demoParameters() {
        MGJRouter.register("mgj://search/:query") { dict in
            self.append(log: "匹配到了 url，以下是相关信息")
            self.append(log: "routerParameters:\(dict)")
        }

        MGJRouter.open("mgj://search/bicycle?color=red")
    }

    func demoCompletion() {
        MGJRouter.register("mgj://detail") { dict in
            print("匹配到了 url, 一会会执行 Completion Block")

            // 模拟 push 一个 VC
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {

                let completion = dict[MGJRouterParameterCompletion] as? MGJRouterCompletionHandle
                if let completion = completion {
                    completion(nil)
                }
            }
        }

        MGJRouter.open("mgj://detail", with: nil) { _ in
            self.append(log: "Open 结束，我是 Completion Block")
        }
    }

    func demoGenerateURL() {
        let TEMPLATE_URL = "mgj://search/:keyword"

        MGJRouter.register(TEMPLATE_URL) { dict in
            guard let value = dict["keyword"] else { return }
            print("routerParameters[keyword]:\(value)") // Hangzhou
        }

        MGJRouter.open(MGJRouter.generateURL(with: TEMPLATE_URL, parameters: ["Hangzhou"]))
    }

    func demoDeregisterURLPattern() {
        let TEMPLATE_URL = "mgj://search/:keyword"

        MGJRouter.register(TEMPLATE_URL) { dict in
            assert(false, "这里不会被触发")
            print("routerParameters[keyword]:\(dict["keyword"])") // Hangzhou
        }

        MGJRouter.deregister(URLPattern: TEMPLATE_URL)

        MGJRouter.open(MGJRouter.generateURL(with: TEMPLATE_URL, parameters: ["Hangzhou"]))
        append(log: "如果没有运行到断点，就表示取消注册成功了")
    }

    func demoObjectForURL() {
        MGJRouter.register(URLPattern: "mgj://search_top_bar") { _ in
            let searchTopBar = UIView()
            return searchTopBar
        }

        let searchTopBar = MGJRouter.object(for: "mgj://search_top_bar")

        if searchTopBar as? UIView != nil {
            append(log: "同步获取 Object 成功")
        } else {
            append(log: "同步获取 Object 失败")
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of _: Any?, change _: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        guard keyPath == "contentSize" else { return }
        let contentHeight = resultTextView.contentSize.height
        let textViewHeight = resultTextView.frame.height
        resultTextView.setContentOffset(CGPoint(x: 0, y: max(contentHeight - textViewHeight, 0)), animated: true)
    }

    deinit {
        resultTextView.removeObserver(self, forKeyPath: "contentSize")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
