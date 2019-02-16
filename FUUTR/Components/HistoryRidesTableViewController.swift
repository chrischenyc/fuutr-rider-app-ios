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
  
  private var apiTask: URLSessionTask?
  
  // MARK: - lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.applyLightTheme()
    
    tableView.tableFooterView = UIView(frame: .zero)
    
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
    return rides.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryRideCell", for: indexPath) as! HistoryRideCell
    
    let ride = rides[indexPath.row]
    cell.updateContent(withRide: ride)
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: R.segue.historyRidesTableViewController.showHistoryRide, sender:rides[indexPath.row])
  }
  
  // MARK: - private
  
  private func loadRides() {
    apiTask?.cancel()
    
    showLoading()
    
    apiTask = RideService.getHistoryRides({ [weak self] (rides, error) in
      DispatchQueue.main.async {
        self?.dismissLoading()
        
        guard error == nil else {
          self?.alertError(error!)
          return
        }
        
        guard let rides = rides else {
          self?.alertMessage(message: R.string.localizable.kOtherError())
          return
        }
        
        self?.rides = rides
        self?.loadRidesContent()
      }
    })
  }
  
  private func loadRidesContent() {
    tableView.reloadData()
    
    // TODO: add call for action UI in case of zero records
  }
}
