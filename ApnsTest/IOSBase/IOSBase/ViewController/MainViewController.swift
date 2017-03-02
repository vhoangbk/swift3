//
//  MainViewController.swift
//  IOSBase
//
//  Created by paraline on 2/22/17.
//  Copyright © 2017 paraline. All rights reserved.
//

import UIKit

class MainViewController: BaseViewController {
    
    @IBOutlet weak var tableview: UITableView!
    
    let datas : [String] = ["A", "B", "C"];

    @IBOutlet weak var textview: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableview.delegate = self;
        tableview.dataSource = self;
        let nibCell1 = UINib(nibName: "MainTableViewCell", bundle: nil);
        self.tableview.register(nibCell1, forCellReuseIdentifier: "MainCell");
        
        
        
    }
    
    override func isHideNavigation() -> Bool {
        return true;
    }

   
    @IBAction func pressToken(_ sender: Any) {
        self.textview.text = UserDefaults.standard.object(forKey: "device_tocken") as! String!;
    }

}

//MARK - UITableViewDataSource
extension MainViewController : UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell : MainTableViewCell = self.tableview.dequeueReusableCell(withIdentifier: "MainCell") as! MainTableViewCell
        
        cell.lbTitle.text = datas[indexPath.row];
        
        return cell;
    }
}

//MARK - UITableViewDelegate
extension MainViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let cell : MainTableViewCell = tableview.cellForRow(at: indexPath) as! MainTableViewCell;
        cell.setSelected(false, animated: true);
        

    }
}
