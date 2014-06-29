//
//  ViewController.swift
//  TwitterSwiftTutorial
//
//  Created by 小峰央志 on 2014/06/29.
//  Copyright (c) 2014年 hssh. All rights reserved.
//

import UIKit
import Accounts
import Social

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView

    var dataSource: NSDictionary[] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        getTimeLine()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count;
    }

    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
        if (!cell) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        }
        cell!.text = dataSource[indexPath.row]["text"] as String
        return cell
    }

    func getTimeLine() {
        let account = ACAccountStore()
        let accountType: ACAccountType = account.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)

        account.requestAccessToAccountsWithType(
            accountType,
            options: nil,
            completion: { granted, error in
                if granted {
                    let accounts = account.accountsWithAccountType(accountType)
                    if accounts.count > 0 {
                        let twitterAccount = accounts[accounts.count - 1] as ACAccount;
                        let requestURL = NSURL.URLWithString("https://api.twitter.com/1.1/statuses/user_timeline.json")
                        let parameters = [
                            "screen_name": "hssh",
                            "include_rts": "0",
                            "trim_user":   "1",
                            "count":       "20",
                        ]

                        let request = SLRequest(
                            forServiceType: SLServiceTypeTwitter,
                            requestMethod: SLRequestMethod.GET,
                            URL: requestURL,
                            parameters: parameters
                        )
                        request.account = twitterAccount

                        request.performRequestWithHandler({ responseData, urlResponse, error in
                            self.dataSource = NSJSONSerialization.JSONObjectWithData(
                                responseData,
                                options: NSJSONReadingOptions.MutableLeaves,
                                error: nil
                            ) as NSDictionary[]

                            if self.dataSource.count > 0 {
                                dispatch_async(dispatch_get_main_queue(), { self.tableView.reloadData() })
                            }
                        })
                    }
                } else {
                    // Handle failure to get account access
                }
            }
        )
    }
}

