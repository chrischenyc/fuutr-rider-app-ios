//
//  WalletViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 1/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import Stripe

class WalletViewController: UIViewController {
  
  @IBOutlet weak var balanceLabel: UILabel!
  @IBOutlet weak var paymentMethodsButton: UIButton!
  @IBOutlet weak var paymentHistoryButton: UIButton!
  @IBOutlet weak var balanceHistoryButton: UIButton!
  
  
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
    
    navigationController?.navigationBar.applyLightTheme()
    paymentMethodsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    paymentMethodsButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
    paymentHistoryButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    paymentHistoryButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
    balanceHistoryButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    balanceHistoryButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
    
    loadProfile()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    
    // needed to clear the text in the back navigation:
    self.navigationItem.title = " "
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationItem.title = "Wallet"
  }
  
  // MARK: - user actions
  @IBAction func unwindToWallet(_ unwindSegue: UIStoryboardSegue) {
    // let sourceViewController = unwindSegue.source
    // Use data from the view controller which initiated the unwind segue
    
    if unwindSegue.identifier == R.segue.topUpViewController.unwindToWallet.identifier {
      // refresh profile in case user has topped up balance
      loadProfile()
    }
  }
  
  @IBAction func paymentMethodsButtonTapped(_ sender: Any) {
    // present Stripe UI
    paymentContext.pushPaymentMethodsViewController()
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
    self.balanceLabel.text = user.balance.priceString
  }
  
}
