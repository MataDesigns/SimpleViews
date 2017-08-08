//
//  ViewController.swift
//  SimpleViewsExample
//
//  Created by Nicholas Mata on 7/29/17.
//  Copyright © 2017 MataDesigns. All rights reserved.
//

import UIKit
import SimpleViews

class PostCell :UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var body: UILabel!
}

class ViewController: UIViewController, UITableViewDataSource, SimpleViewDelegate {
    
    @IBOutlet weak var tableView: SimpleTableView!
    
    @IBOutlet weak var loadingView: SimpleStateView!
    @IBOutlet weak var emptyView: SimpleStateView!
    
    var posts = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.simpleDelegate = self
        tableView.isHidden = true
        // Do any additional setup after loading the view, typically from a nib.
        let urlString = "http://jsonplaceholder.typicode.com/posts"
        guard let requestUrl = URL(string:urlString) else { return }
        let request = URLRequest(url:requestUrl)
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if error == nil,let usableData = data {
                guard let json = try? JSONSerialization.jsonObject(with: usableData, options: []) as! [[String:Any]] else {
                    return
                }
                
                self.posts.append(contentsOf: json)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
                    self.tableView.fetched = true;
                    self.tableView.reloadData()
                })
            }
        }
        
        task.resume()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.initialize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        let post = self.posts[indexPath.row]
        cell.title.text = post["title"] as? String
        cell.body.text = post["body"] as? String
        return cell;
    }
    
    func transition(forState state: SimpleViewState) -> SimpleTransition {
        switch state {
        case .finished:
            return .slideUp
        case .loading:
            return .slideUp
        case.empty:
            return .fade
        }
    }
    
    func transitionOut(forState state: SimpleViewState) -> SimpleTransition {
        switch state {
        case .finished:
            return .slideDown
        case .loading:
            return .slideDown
        case.empty:
            return .fade
        }
    }
    
    func view(forState state: SimpleViewState) -> UIView {
        switch state {
        case .finished:
            return self.tableView
        case .loading:
            return self.loadingView
        case.empty:
            return self.emptyView
        }
    }
}

