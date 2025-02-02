//
//  WalletViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 1/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import Stripe

class WalletViewController: UIViewController, Coordinatable {
    var cooridnator: Coordinator?
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var paymentMethodsButton: UIButton!
    @IBOutlet weak var paymentHistoryButton: UIButton!
    @IBOutlet weak var balanceHistoryButton: UIButton!
    
    
    private var apiTask: URLSessionTask?
    private var paymentContext: STPPaymentContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let customerContext = STPCustomerContext(keyProvider: PaymentService())
        paymentContext = STPPaymentContext(customerContext: customerContext)
        paymentContext?.configuration.canDeletePaymentMethods = true
        paymentContext?.hostViewController = self
        
        navigationController?.navigationBar.applyLightTheme()
        paymentMethodsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        paymentMethodsButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
        paymentHistoryButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        paymentHistoryButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
        balanceHistoryButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        balanceHistoryButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
        
        loadProfile()
    }
    
    // MARK: - user actions
    @IBAction func unwindToWallet(_ unwindSegue: UIStoryboardSegue) {
        // let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
        
        if let _ = unwindSegue.source as? TopUpViewController {
            loadProfile()
        }
    }
    
    @IBAction func paymentMethodsButtonTapped(_ sender: Any) {
        // present Stripe UI
        paymentContext?.pushPaymentMethodsViewController()
    }
    
    private func loadProfile() {
        apiTask?.cancel()
        
        showLoading()
        
        apiTask = UserService.getProfile({[weak self] (user, error) in
            DispatchQueue.main.async {
                self?.dismissLoading()
                
                guard error == nil else {
                    self?.alertError(error!)
                    return
                }
                
                guard let user = user else { return }
                
                self?.loadUserContent(user)
            }
        })
    }
    
    private func loadUserContent(_ user: User) {
        self.balanceLabel.text = user.balance.priceString
    }
    
}
