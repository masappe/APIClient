//
//  WebViewController.swift
//  APIClient
//
//  Created by Masato Hayakawa on 2019/02/23.
//  Copyright © 2019 masappe. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet weak var wkWebView: WKWebView!
    var readUrl:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: readUrl)
        let myRequest = URLRequest(url: url!)
        wkWebView.load(myRequest)

        // Do any additional setup after loading the view.
    }
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}
