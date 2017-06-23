//
//  ViewController.swift
//  WLRRoute.swift
//
//  Created by 伯驹 黄 on 2017/2/7.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(push))
    }

    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        push()
    }

    func push() {
        MTRouter.excute(uri: "WLRDemo://page/signin/?q=13812345432///、")
        //        WLRRouter.handle(urlStr: "WLRDemo://com.wlrroute.demo/signin/13812345432", primitiveParameters: nil, targetCallBack: { (error, responseObject) in
        //        }) { (handled) in
        //        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
