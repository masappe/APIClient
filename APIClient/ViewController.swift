//
//  ViewController.swift
//  APIClient
//
//  Created by Masato Hayakawa on 2019/02/20.
//  Copyright © 2019 masappe. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableview: UITableView!
    //Dictionary型を入れる配列
    var datas: [[String:String?]] = []
    //webのpageを示す
    var page = 1
    //データの読み込み状態などを示す
    var loadStatus = "init"
    //送るurl
    var sendUrl:String!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        getdata(number: page)
        //xibの登録
        let nib = UINib(nibName: "TableViewCell", bundle: nil)
        self.tableview.register(nib, forCellReuseIdentifier: "OriginalCell")
        //delegate,datasource
        tableview.delegate = self
        tableview.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //最初にデータが読み込まれるまで待機
        while loadStatus == "fetching" || loadStatus == "init" {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
        }
        tableview.reloadData()
    }
    //cellがタップされた時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sendUrl = datas[indexPath.row]["url"] as? String
        performSegue()
    }
    
    func performSegue(){
        performSegue(withIdentifier: "toNext", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNext"{
            let webViewController = segue.destination as! WebViewController
            webViewController.readUrl = self.sendUrl
        }
    }
    
    //テーブルの一番下まで行ったかを検知
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard tableView.cellForRow(at: IndexPath(row: tableView.numberOfRows(inSection: 0)-1, section: 0)) != nil else {
            return
        }
        //データの取得
        getdata(number: page)
        //データをし取得しきるまで待機
        while loadStatus == "fetching" {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.01))
        }
        tableview.reloadData()
    }
    
//    cellの個数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    //cellのデータ
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OriginalCell") as? TableViewCell
        let data = datas[indexPath.row]
        cell?.titleLabel.text = data["title"]!
        cell?.nameLabel.text = data["id"]!
        cell?.dateLabel.text = data["date"]!
        //Kingfisherを使用
//        let url = URL(string: data["image"]!!)
//        cell?.userImage.kf.setImage(with: url)
        let url = URL(string: data["image"]!!)
        //システムで用意してくれたキューを用いて非同期にそ処理を行う
        //処理が重いものはスレッドを分けてプログラムを書く
        DispatchQueue.global().async {
            let userImage = try? Data(contentsOf: url!)
            //UIはmainスレッドで行う
            DispatchQueue.main.async {
                cell?.userImage.image = UIImage(data: userImage!)
            }
        }
        return cell!
    }
    
    //データの取得
    func getdata(number:Int){
        //fetching,fullだとデータを取得しない
        guard loadStatus != "fetching" && loadStatus != "full" else{return}
        loadStatus = "fetching"
        //urlを取得
        let url = "https://qiita.com/api/v2/items?page=" + String(number)
        //データを取得しに行く
        Alamofire.request(url).responseJSON { response in
            //データがなかったらreturn
            guard let object = response.result.value else{
                return
            }
            //swiftyjsonを用いてjsonを簡単に分解できるようにする
            let json = JSON(object)
            //jsonデータを分解して格納
            json.forEach{(index,json) in
                let value = json["created_at"].string!
                let date = value.prefix(10)
                let data: [String:String] = [
                    "title" : json["title"].string!,
                    "id" : json["user"]["id"].string!,
                    "date" : String(date),
                    "image" : json["user"]["profile_image_url"].string!,
                    "url" : json["url"].string!
                ]
                self.datas.append(data)
            }
            //データを読み込んだら状態を変化させる
            self.loadStatus = "loadMore"
        }
        page = page + 1
        //10ページ以上読み込めないようにする
        if page >= 10{
            loadStatus = "full"
            let alert = UIAlertController(title: "Error", message: "これ以上記事をみ読み込めません", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
            return
        }
    }


}

