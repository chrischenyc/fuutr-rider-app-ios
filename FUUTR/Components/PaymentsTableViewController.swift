//
//  PaymentsTableViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 11/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit

class PaymentsTableViewController: UITableViewController {
  
  private var payments: [Payment] = []
  private var didLoadPayments = false
  
  private var apiTask: URLSessionTask?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.tableFooterView = UIView(frame: .zero)
    
    loadPayments()
  }
  
  // MARK: - Table view data source
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard didLoadPayments else { return 0 }
    return payments.count > 0 ? payments.count : 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if payments.count > 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as! PaymentCell
      
      let payment = payments[indexPath.row]
      cell.loadPayment(payment)
      
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "NoPaymentCell", for: indexPath)
      
      return cell
    }
  }
  
  private func loadPayments() {
    apiTask?.cancel()
    
    showLoading()
    
    apiTask = PaymentService.getHistoryPayments(completion: { [weak self] (payments, error) in
      DispatchQueue.main.async {
        self?.dismissLoading()
        
        self?.didLoadPayments = true
        
        
        guard error == nil else {
          self?.alertError(error!)
          return
        }
        
        guard let payments = payments else { return }
        
        
        self?.payments = payments
        self?.tableView.separatorStyle = payments.count > 0 ? .singleLine : .none
        self?.tableView.reloadData()
      }
    })
  }
}
