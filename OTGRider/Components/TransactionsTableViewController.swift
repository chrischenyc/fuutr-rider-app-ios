//
//  TransactionsTableViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 17/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit

class TransactionsTableViewController: UITableViewController {
    
    private var transactions: [Transaction] = []
    
    private var apiTask: URLSessionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: .zero)
        
        loadTransactions()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionCell
        
        let transaction = transactions[indexPath.row]
        cell.loadTransaction(transaction)
        
        return cell
    }
    
    private func loadTransactions() {
        apiTask?.cancel()
        
        showLoading()
        
        apiTask = TransactionService.getHistoryTransactions(completion: { [weak self] (transactions, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    self?.flashErrorMessage(error?.localizedDescription)
                    return
                }
                
                guard let transactions = transactions else {
                    self?.flashErrorMessage(L10n.kOtherError)
                    return
                }
                
                self?.dismissLoading()
                self?.transactions = transactions
                self?.loadPaymentsContent()
            }
        })
    }
    
    private func loadPaymentsContent() {
        tableView.reloadData()
        
        // TODO: add call for action UI in case of zero records
    }
    
}
