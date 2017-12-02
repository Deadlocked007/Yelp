//
//  BusinessesViewControllerTableViewController.swift
//  Yelp
//
//  Created by Siraj Zaneer on 12/2/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit
import AFNetworking

class BusinessesViewControllerTableViewController: UITableViewController {

    @IBOutlet weak var filterButton: UIButton!
    
    let searchController = UISearchController(searchResultsController: nil)
    var leftHolder: UIBarButtonItem!
    let locationManager = CLLocationManager()
    var businesses: [Business] = []
    var offset = 0
    var searchText = "Chicken"
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 116
        
        filterButton.layer.borderWidth = 1.0
        filterButton.layer.borderColor = UIColor.white.cgColor
        filterButton.layer.cornerRadius = 5
        filterButton.clipsToBounds = false
        filterButton.layer.shadowColor = UIColor.white.cgColor
        filterButton.layer.shadowOpacity = 1
        filterButton.layer.shadowOffset = CGSize.zero
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Restaurants"
        searchController.delegate = self
        searchController.searchBar.delegate = self
        
        navigationItem.titleView = searchController.searchBar
        
        setupLocation()
    }
    
    func setupLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.startUpdatingLocation()
        
        loadBusinesses()
    }
    
    func loadBusinesses() {
        isLoading = true
        guard let location = locationManager.location else {
            Business.searchWithTerm(term: searchText, sort: YelpSortMode.distance, categories: nil, deals: nil) { (businesses, error) in
                if let error = error {
                    print(error)
                    self.isLoading = false
                } else if let businesses = businesses {
                    self.businesses = businesses
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.tableView.reloadData()
                    }
                }
            }
            return
        }
        
        Business.searchWithTerm(term: searchText, ll: "\(location.coordinate.latitude),\(location.coordinate.longitude)", sort: YelpSortMode.distance, categories: nil, deals: nil) { (businesses, error) in
            if let error = error {
                print(error)
                self.isLoading = false
            } else if let businesses = businesses {
                self.businesses = businesses
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return businesses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "businessCell", for: indexPath) as! BusinessCell

        let business = businesses[indexPath.row]
        
        cell.businessImageView.image = nil
        cell.nameLabel.text = business.name
        cell.addressLabel.text = business.address
        cell.cuisineLabel.text = business.categories
        cell.reviewsLabel.text = "\(business.reviewCount!) Reviews"
        cell.ratingView.setImageWith(business.ratingImageURL!)
        cell.distanceLabel.text = "\(business.distance!)"
        if let imageURL = business.imageURL {
            
            cell.businessImageView.setImageWith(imageURL)
        }
        cell.businessImageView.layer.cornerRadius = 5
        
        return cell
    }
    

}

extension BusinessesViewControllerTableViewController: UISearchBarDelegate, UISearchControllerDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchText = "Chicken"
        loadBusinesses()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchText = searchBar.text!
        loadBusinesses()
    }
    func willPresentSearchController(_ searchController: UISearchController) {
        leftHolder = navigationItem.leftBarButtonItem
        navigationItem.leftBarButtonItem = nil
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        navigationItem.leftBarButtonItem = leftHolder
    }
    
}

