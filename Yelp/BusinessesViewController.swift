//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit


class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FiltersViewControllerDelegate  {

    var businesses: [Business]!
     var searchText = ""
    
    //Declare variables to Search Bar
    var searchBar: UISearchBar!
   
    
   // var client: YelpClient!
    var refreshControl: UIRefreshControl!

    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
         customizeNavBarTitleView()
        
         setupTableView()
         self.tableView.reloadData()
        
        //Pull to refresh tableView
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        
        self.tableView?.addSubview(refreshControl)

        
       
       // Business.searchWithTerm("Thai", completion: { (businesses: [Business]!, error: NSError!) -> Void in
        //    self.businesses = businesses
        //    self.tableView.reloadData()
            
       //    for business in businesses {
       //         print(business.name!)
       //         print(business.address!)
       //     }
       // })
        
//        Business.searchWithTerm("Restaurants", sort: .Distance, categories:
//            ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
//            self.businesses = businesses
//            self.tableView.reloadData()
//            
//           for business in businesses {
//                print(business.name!)
//                print(business.address!)
//            }
//        }
        
        searchBar.text = "Thai"
        searchWithTerm(searchBar.text!)
       
    }
    func customizeNavBarTitleView() {
        // initialize UISearchBar
        searchBar = UISearchBar()
        
        searchBar.delegate = self
        
        // add search bar to navigation bar
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
            
        
        //Dynamic cell
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
    }
        
    func searchWithTerm(term :String) {
         CozyLoadingActivity.show("Loading...", disableUI: true)
         Business.searchWithTerm(term, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        
            for business in businesses {
                 print(business.name!)
                 print(business.address!)
                 CozyLoadingActivity.hide(success: true, animated: true)
             }
            CozyLoadingActivity.hide(success: false, animated: true)
            
         })
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchWithTerm(searchBar.text!)
        searchBar.resignFirstResponder()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
           return businesses!.count
        } else {
            return 0
        }
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        cell.business = businesses[indexPath.row]
        return cell
        
    }
    
      
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        let navigationController = segue.destinationViewController as! UINavigationController
        let filtersViewController1 = navigationController.topViewController as! FiltersViewController
        
        // Pass the selected object to the new view controller.
        filtersViewController1.delegate = self
        filtersViewController1.searchText = self.searchBar.text!
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String: AnyObject]) {
        let categories = filters["categories"] as? [String]
       
        Business.searchWithTerm(searchBar.text!, sort: nil, categories: categories, deals: nil) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses  = businesses
            self.tableView.reloadData()
        }

   }

}

