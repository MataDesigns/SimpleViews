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
    
    @IBOutlet weak var errorSwitch: UISwitch!
    @IBOutlet weak var errorSwitchLabel: UILabel!
    
    var posts = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.simpleDelegate = self
        tableView.isHidden = true
        
        let urlString = "http://jsonplaceholder.typicode.com/posts"
        guard let requestUrl = URL(string:urlString) else { return }
        let request = URLRequest(url:requestUrl)
        
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 5) {
            
            let task = URLSession.shared.dataTask(with: request) {
                (data, response, error) in
                if error == nil,let usableData = data {
                    guard let jsonData = try? JSONSerialization.jsonObject(with: usableData, options: [])else {
                        self.tableView.state = .failed
                        return
                    }
                    
                    guard let json = jsonData as? [[String: Any]] else {
                        self.tableView.state = .failed
                        return
                    }
                    
                    DispatchQueue.main.sync {
                        self.errorSwitchLabel.textColor = .lightGray
                        self.errorSwitch.isEnabled = false
                    }
                    
                    guard !self.errorSwitch.isOn else {
                        self.tableView.state = .failed
                        return
                    }
                    
                    self.posts.append(contentsOf: json)
                    
                    DispatchQueue.main.sync {
                        self.tableView.fetched = true;
                        self.tableView.reloadData()
                    }
                } else if error != nil {
                    self.tableView.state = .failed
                }
            }
            task.resume()
        }
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
    
    func changed(from oldState: SimpleViewState, to state: SimpleViewState) {
        switch state {
        case .finished:
            UIView.animate(withDuration: 0.0, animations: {
                self.errorSwitchLabel.isHidden = true
                self.errorSwitch.isHidden = true
            })
            break
        case .loading:
            break
        case .empty:
            break
        case.failed:
            DispatchQueue.main.async {
                self.loadingView.backgroundColor = .red
            }
        }
        
    }
    
    func transition(forState state: SimpleViewState) -> SimpleTransition {
        switch state {
        case .finished:
            return .slideUp
        case .loading:
            return .slideUp
        case.empty:
            return .fade
        case .failed:
            return .none
        }
    }
    
    func transitionOut(forState state: SimpleViewState) -> SimpleTransition {
        switch state {
        case .finished:
            return .slideDown
        case .loading:
            return .slideDown
        case .empty:
            return .fade
        case .failed:
            return .none
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
        case .failed:
            return self.loadingView
        }
    }
}

