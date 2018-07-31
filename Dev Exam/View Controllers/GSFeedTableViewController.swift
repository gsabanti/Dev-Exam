//
//  GSFeedTableViewController.swift
//  Dev Exam
//
//  Created by George Sabanov on 31.07.2018.
//  Copyright © 2018 George Sabanov. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import SDWebImage

class GSFeedTableViewController: UITableViewController {
    var sorting: SortingStyle = .server
    let realm = try! Realm()
    var notificationToken: NotificationToken? = nil
    var timer: Timer?
    var elements: Results<DataElement>
    {
        switch sorting {
        case .server:
            let data = realm.objects(DataElement.self).sorted(byKeyPath: "sort")
            return data
        case .date:
            let data = realm.objects(DataElement.self).sorted(byKeyPath: "date")
            return data
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadData(completion: nil)
        self.configureRefreshControl()
        self.configureNavigationBar()
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true, block: { [weak self](timer) in
            self?.refresh()
        })
        
    }
    
    func configureNavigationBar()
    {
        guard self.navigationController != nil else { return }
        let exitItem = UIBarButtonItem(image: #imageLiteral(resourceName: "exit_icon"), style: .done, target: self, action: #selector(exit))
        self.navigationItem.leftBarButtonItem = exitItem
        let refreshItem = UIBarButtonItem(image: #imageLiteral(resourceName: "refresh_icon"), style: .done, target: self, action: #selector(refreshButtonTapped))
        self.navigationItem.rightBarButtonItem = refreshItem
    }
    @objc func exit()
    {
        self.navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
        AuthManager.exit()
    }
    func configureRefreshControl()
    {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        self.refreshControl = control
    }
    @objc func refreshButtonTapped()
    {
        reloadData { 
            
        }
    }
    @objc func refresh(sender: UIRefreshControl? = nil)
    {
        sender?.beginRefreshing()
        reloadData { 
            sender?.endRefreshing()
        }
    }
    
    func reloadData(completion:(()->())?)
    {
        FeedManager.getFeed(success: { [weak self](elements) in
            DispatchQueue.main.async {
                completion?()
            }
        }) { [weak self] (failureString) in
            DispatchQueue.main.async {
                self?.showFailureAlert(message: failureString)
                completion?()
            }
        }
    }
    
    @IBAction func sortAction(_ sender: UISegmentedControl)
    {
        let style = SortingStyle(rawValue: sender.selectedSegmentIndex) ?? .server
        self.changeSorting(toType: style)
    }
    
    
    func changeSorting(toType type: SortingStyle)
    {
        self.sorting = type
        self.tableView.reloadData()
        resubscribeToUpdates()
    }
    
    func resubscribeToUpdates()
    {
        DispatchQueue.main.async {
            self.notificationToken?.invalidate()
            self.notificationToken = self.elements.observe { [weak self] (changes: RealmCollectionChange) in
                guard let tableView = self?.tableView else { return }
                switch changes {
                case .initial:
                    // Results are now populated and can be accessed without blocking the UI
                    tableView.reloadData()
                case .update(_, let deletions, let insertions, let modifications):
                    // Query results have changed, so apply them to the UITableView
                    tableView.beginUpdates()
                    tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                         with: .automatic)
                    tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                         with: .automatic)
                    tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                         with: .automatic)
                    tableView.endUpdates()
                case .error(let error):
                    // An error occurred while opening the Realm file on the background worker thread
                    fatalError("\(error)")
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return elements.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedTableViewCell
        let element = self.elements[indexPath.row]
        cell.picImageView.sd_setImage(with: URL(string: element.image ?? ""), placeholderImage: #imageLiteral(resourceName: "no_photo"), options: SDWebImageOptions.allowInvalidSSLCertificates, completed: nil)
        cell.titleLabel.text = element.title
        cell.descLabel.text = element.text
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        cell.dateLabel.text = formatter.string(from: element.date ?? Date())

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let element = self.elements[indexPath.row]
        let detailedVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detailed_feed") as! GSDetailedElementViewController
        detailedVC.element = element
        self.show(detailedVC, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    deinit {
        self.timer?.invalidate()
        self.timer = nil
        self.notificationToken?.invalidate()
        self.notificationToken = nil
    }
}

enum SortingStyle: Int {
    case server = 0
    case date = 1
}
