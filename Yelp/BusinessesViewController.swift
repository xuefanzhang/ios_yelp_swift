//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchBarDelegate {

    var businesses: [Business]!
    
    @IBOutlet weak var tableView: UITableView!
    lazy var searchBar:UISearchBar = UISearchBar(frame: CGRectMake(0, 0, 100, 20))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = searchBar
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        searchBar.delegate = self
        
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: nil, deals: nil, radius: nil) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection secion: Int) -> Int {
        if businesses != nil {
            return businesses.count
        } else {
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        
        cell.business = businesses[indexPath.row]
        
        return cell
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let searchText = searchBar.text
        
        Business.searchWithTerm(searchText!, sort: .Distance, categories: nil, deals: nil, radius: nil) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navigationController = segue.destinationViewController as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        
        filtersViewController.delegate = self
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String:AnyObject]){
        
        let categories = filters["categories"] as? [String]
        let dealOn = filters["deals"] as? Bool
        let sort = filters["sort"] as? Int
        var radius = filters["radius"] as? Int
        
        if radius != nil {
            radius = radius! * 1600     //convert from mile to meter before passing to API
        }
        
        Business.searchWithTerm("Restaurants", sort: YelpSortMode(rawValue: sort!), categories: categories, deals: dealOn, radius: radius ) {
            (businesses:[Business]!, error:NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        }
    }

}
