//
//  HistoryRidesTableViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 17/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit

class HistoryRidesTableViewController: UITableViewController {
  
  private var rides: [Ride] = []
  var selectedRide: Ride?
  
  private var apiTask: URLSessionTask?
  
  // MARK: - lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.tableFooterView = UIView(frame: .zero)
    
    loadRides()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let rideFinishedViewController = segue.destination as? RideFinishedViewController,
      let ride = sender as? Ride {
      rideFinishedViewController.ride = ride
    }
  }
  
  // MARK: - Table view data source
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return rides.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryRideCell", for: indexPath) as! HistoryRideCell
    
    let ride = rides[indexPath.row]
    cell.updateContent(withRide: ride)
    
    return cell
  }
  
  private func loadRides() {
    apiTask?.cancel()
    
    showLoading()
    
    apiTask = RideService.getHistoryRides({ [weak self] (rides, error) in
      DispatchQueue.main.async {
        self?.dismissLoading()
        
        guard error == nil else {
          self?.flashErrorMessage(error?.localizedDescription)
          return
        }
        
        guard let rides = rides else {
          self?.flashErrorMessage(R.string.localizable.kOtherError())
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
  
  // MARK: - TableView delegate
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: R.segue.historyRidesTableViewController.showRideSummary, sender:rides[indexPath.row])
  }
}
