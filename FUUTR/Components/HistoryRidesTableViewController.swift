//
//  HistoryRidesTableViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 17/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit

class HistoryRidesTableViewController: UITableViewController {
  
  private var rides: [Ride] = []
  private var didLoadRides = false
  
  private var apiTask: URLSessionTask?
  
  // MARK: - lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.applyLightTheme()
    
    loadRides()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let historyRideViewController = segue.destination as? HistoryRideViewController,
      let ride = sender as? Ride {
      historyRideViewController.ride = ride
    }
  }
  
  // MARK: - Table view data source and delegate
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard didLoadRides else { return 0 }
    return rides.count > 0 ? rides.count : 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if rides.count > 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryRideCell", for: indexPath) as! HistoryRideCell
        
        let ride = rides[indexPath.row]
        cell.updateContent(withRide: ride)
        
        return cell
    } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoRideCell", for: indexPath)
        
        return cell
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard rides.count > 0 else { return }
    
    performSegue(withIdentifier: R.segue.historyRidesTableViewController.showHistoryRide, sender:rides[indexPath.row])
  }
  
  // MARK: - private
  
  private func loadRides() {
    apiTask?.cancel()
    
    showLoading()
    
    apiTask = RideService.getHistoryRides({ [weak self] (rides, error) in
      DispatchQueue.main.async {
        self?.dismissLoading()
        
        self?.didLoadRides = true
        
        guard error == nil else {
          self?.alertError(error!)
          return
        }
        
        guard let rides = rides else { return }
        
        self?.rides = rides
        self?.tableView.reloadData()
      }
    })
  }
}
