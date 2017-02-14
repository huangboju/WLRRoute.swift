//
//  SecondController.swift
//  WLRRoute.swift
//
//  Created by 伯驹 黄 on 2017/2/14.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

class SecondController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.red

        print(wlr_request?["phone"])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
