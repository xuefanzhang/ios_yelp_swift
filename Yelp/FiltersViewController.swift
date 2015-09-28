//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Xuefan Zhang on 9/26/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String:AnyObject])
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    weak var delegate: FiltersViewControllerDelegate?
    
    var sections = [("Deal", ["Offering a Deal"]), ("Categories", ["hi","bye"])]
    var categories: [[String:String]]!
    var switchStates = [Int:[Int:Bool]]()
    
    var selectedRadius = 0
    var selectedSort = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        categories = yelpCategories()
        var categoryNames = [String]()
        for category in categories {
            categoryNames.append(category["name"]!)
        }
        sections = [("Deal", ["Offering a Deal"]), ("Radius in Miles", ["5", "3", "1"]), ("Sort", ["Best Match", "Distance", "Highest Rated"]), ("Categories", categoryNames)]
        
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier)
        //tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: SwitchCell)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onSearchButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        
        var filters = [String:AnyObject]()
        
        var selectedCategories = [String]()
        
        for (sectionNum, dict) in switchStates {
            for (rowNum, value) in dict{
                if value {
                    if (sectionNum == 0){   //deal
                        filters["deals"] = value
                    } else if (sectionNum == 3) {   //categories
                        selectedCategories.append(categories[rowNum]["code"]!)
                    }
                }
            }
            
        }
        
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories
        }
        
        filters["radius"] = Int(sections[1].1[selectedRadius])
        filters["sort"] = selectedSort
        
        delegate?.filtersViewController?(self, didUpdateFilters: filters)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].1.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.section == 0 || indexPath.section == 3){
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            cell.switchLabel.text = sections[indexPath.section].1[indexPath.row]
            cell.delegate = self
            var state = switchStates[indexPath.section]?[indexPath.row]
            cell.onSwitch.on = state ?? false
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("PickerCell", forIndexPath: indexPath) as! PickerCell
            cell.pickLabel.text = sections[indexPath.section].1[indexPath.row]
            
            if tableView.numberOfRowsInSection(indexPath.section) == 1 {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }else {
                if (indexPath.section == 1){
                    if (indexPath.row == selectedRadius){
                        cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryType.None
                    }
                } else if (indexPath.section == 2){
                    if (indexPath.row == selectedSort){
                        cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryType.None
                    }
                }
            }
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].0
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPathForCell(switchCell)!
        switchStates[indexPath.section] = [indexPath.row:value]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 1 {
            selectedRadius = indexPath.row
        } else if indexPath.section == 2 {
            selectedSort = indexPath.row
        }
        tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func yelpCategories() -> [[String:String]] {
        return  [["name" : "Afghan", "code": "afghani"],
        ["name" : "African", "code": "african"],
        ["name" : "American, New", "code": "newamerican"],
        ["name" : "American, Traditional", "code": "tradamerican"],
        ["name" : "Eastern European", "code": "eastern_european"],
        ["name" : "Ethiopian", "code": "ethiopian"],
        ["name" : "Italian", "code": "italian"],
        ["name" : "Japanese", "code": "japanese"],
        ["name" : "Polish", "code": "polish"]]
    }
}
