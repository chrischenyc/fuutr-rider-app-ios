//
//  PaymentsTableViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 11/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import UIKit

class PaymentsTableViewController: UITableViewController {
    
    private var payments: [Payment] = []
    
    private var apiTask: URLSessionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: .zero)
        
        loadPayments()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as! PaymentCell
        
        let payment = payments[indexPath.row]
        cell.loadPayment(payment)
        
        return cell
    }
    
    private func loadPayments() {
        apiTask?.cancel()
        
        showLoading()
        
        apiTask = UserService().getHistoryPayments(completion: { [weak self] (payments, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    self?.dismissLoading(withMessage: error?.localizedDescription)
                    return
                }
                
                guard let payments = payments else {
                    self?.dismissLoading(withMessage: L10n.kOtherError)
                    return
                }
                
                self?.dismissLoading()
                self?.payments = payments
                self?.loadPaymentsContent()
            }
        })
    }
    
    private func loadPaymentsContent() {
        tableView.reloadData()
    }
    
}