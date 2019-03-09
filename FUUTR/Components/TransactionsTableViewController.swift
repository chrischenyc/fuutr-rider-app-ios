//
//  TransactionsTableViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 17/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit

class TransactionsTableViewController: UITableViewController {
  
  private var transactions: [Transaction] = []
  private var didLoadTransactions = false
  private var apiTask: URLSessionTask?
  @IBOutlet weak var tableHeaderView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.tableFooterView = UIView(frame: .zero)
    tableHeaderView.isHidden = true
    loadTransactions()
  }
  
  // MARK: - Table view data source
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard didLoadTransactions else { return 0 }
    return transactions.count > 0 ? transactions.count : 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if transactions.count > 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionCell
      
      let transaction = transactions[indexPath.row]
      cell.loadTransaction(transaction)
      
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "NoTransactionCell", for: indexPath)
      
      return cell
    }
  }
  
  private func loadTransactions() {
    apiTask?.cancel()
    
    showLoading()
    
    apiTask = TransactionService.getHistoryTransactions(completion: { [weak self] (transactions, error) in
      DispatchQueue.main.async {
        self?.dismissLoading()
        
        self?.didLoadTransactions = true
        
        guard error == nil else {
          self?.alertError(error!)
          return
        }
        
        guard let transactions = transactions else { return }
        
        self?.transactions = transactions
        self?.tableView.separatorStyle = transactions.count > 0 ? .singleLine : .none
        self?.tableHeaderView.isHidden = transactions.count == 0
        self?.tableView.reloadData()
      }
    })
  }
}
