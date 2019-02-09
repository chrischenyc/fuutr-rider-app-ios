//
//  AccountViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 1/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import Stripe

class AccountViewController: UIViewController {
  
  @IBOutlet weak var balanceLabel: UILabel!
  
  private var apiTask: URLSessionTask?
  private let customerContext: STPCustomerContext
  private let paymentContext: STPPaymentContext
  
  required init?(coder aDecoder: NSCoder) {
    customerContext = STPCustomerContext(keyProvider: PaymentService())
    paymentContext = STPPaymentContext(customerContext: customerContext)
    paymentContext.configuration.canDeletePaymentMethods = true
    
    super.init(coder: aDecoder)
    
    paymentContext.hostViewController = self
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadProfile()
  }
  
  
  @IBAction func unwindToAccount(_ unwindSegue: UIStoryboardSegue) {
    // let sourceViewController = unwindSegue.source
    // Use data from the view controller which initiated the unwind segue
    
    if unwindSegue.identifier == R.segue.topUpViewController.unwindToAccount.identifier {
      // refresh profile in case user has topped up balance
      loadProfile()
    }
  }
  
  @IBAction func paymentMethodsButtonTapped(_ sender: Any) {
    // present Stripe UI
    paymentContext.presentPaymentMethodsViewController()
  }
  
  private func loadProfile() {
    apiTask?.cancel()
    
    showLoading()
    
    apiTask = UserService.getProfile({[weak self] (user, error) in
      DispatchQueue.main.async {
        guard error == nil else {
          self?.alertError(error!)
          return
        }
        
        guard let user = user else {
          self?.alertMessage(message: R.string.localizable.kOtherError())
          return
        }
        
        self?.dismissLoading()
        self?.loadUserContent(user)
      }
    })
  }
  
  private func loadUserContent(_ user: User) {
    self.balanceLabel.text = "Balance \(user.balance.currencyString)"
  }
  
}
