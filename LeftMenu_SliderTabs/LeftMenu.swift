//
//  LeftMenu.swift
//  LeftSlideoutMenu
//
//  Created by Robert Chen on 8/5/15.
//  Copyright (c) 2015 Thorn Technologies. All rights reserved.
//

import UIKit

class LeftMenu : UITableViewController {
    
    let menuOptions = ["First Option", "Second Option"]
    
}

// MARK: - UITableViewDelegate methods

extension LeftMenu {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            // MainWindow.swift listens for this
            print("Pressed 1")
        case 1:
            // Both FirstViewController and SecondViewController listen for this
            print("Pressed 2")
        default:
            print("indexPath.row:: \(indexPath.row)")
        }
        
        // also close the menu
        NSNotificationCenter.defaultCenter().postNotificationName("closeMenuViaNotification", object: nil)
        
    }
    
}

// MARK: - UITableViewDataSource methods

extension LeftMenu {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = menuOptions[indexPath.row]
        return cell
    }
    
}