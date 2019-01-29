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
  
  private var apiTask: URLSessionTask?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.tableFooterView = UIView(frame: .zero)
    
    loadRides()
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
  
}
