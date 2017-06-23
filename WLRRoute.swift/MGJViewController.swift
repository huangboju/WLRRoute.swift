//
//  MGJViewController.swift
//  WLRRoute.swift
//
//  Created by 伯驹 黄 on 2017/3/2.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import UIKit

var titleWithHandlers: [String: () -> UIViewController] = [:]
var titles: [String] = []

class MGJViewController: UITableViewController {

    static func register(with title: String, handler: @escaping () -> UIViewController) {
        titles.append(title)
        titleWithHandlers[title] = handler
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {

        return titleWithHandlers.keys.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = titles[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let controller = titleWithHandlers[titles[indexPath.row]]?() else { return }
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
}
