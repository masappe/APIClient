//
//  WebViewController.swift
//  APIClient
//
//  Created by Masato Hayakawa on 2019/02/23.
//  Copyright © 2019 masappe. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController,WKNavigationDelegate {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var wkWebView: WKWebView!
    var readUrl:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: readUrl)
        let myRequest = URLRequest(url: url!)
        wkWebView.navigationDelegate = self
        self.wkWebView.allowsBackForwardNavigationGestures = true
        wkWebView.load(myRequest)
    }
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    //webViewが開始したら呼ばれる
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        //indicatorスタート
        indicator.startAnimating()
    }
    //webViewがコンテンツを呼び出したら呼ばれる
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        //誤差の修正
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
        //indicatorストップ
        indicator.alpha = 0
        indicator.stopAnimating()
    }
}
