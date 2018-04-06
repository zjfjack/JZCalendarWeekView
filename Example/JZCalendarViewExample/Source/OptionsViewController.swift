//
//  OptionsViewController.swift
//  JZCalendarViewExample
//
//  Created by Jeff Zhang on 6/4/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit

class OptionsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBasic()
        setupTableView()
    }
    
    func setupBasic() {
        view.backgroundColor = UIColor.white
        navigationItem.title = "Options"
    }
    
    func setupTableView() {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
