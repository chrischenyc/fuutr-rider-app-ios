//
//  TopUpViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 10/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import Stripe

class TopUpViewController: UIViewController {
  @IBOutlet weak var insufficientFundLabel: UILabel!
  @IBOutlet weak var balanceLabel: UILabel!
  @IBOutlet weak var topupAmountLabel: UILabel!
  @IBOutlet weak var paymentMethodButton: UIButton!
  @IBOutlet weak var payButton: UIButton!
  
  private var paymentContext: STPPaymentContext?
  private var apiTask: URLSessionTask?
  private var amount : Int = 0
  
  // MARK: lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let customerContext = STPCustomerContext(keyProvider: PaymentService())
    paymentContext = STPPaymentContext(customerContext: customerContext)
    paymentContext?.configuration.canDeletePaymentMethods = true
    paymentContext?.paymentCurrency = "aud"
    paymentContext?.delegate = self
    paymentContext?.hostViewController = self
    
    
    navigationController?.navigationBar.applyLightTheme(transparentBackground: false)
    paymentMethodButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    paymentMethodButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
    payButton.isEnabled = false
    
    loadProfile()
  }
  
  
  @IBAction func amountChoosed(_ sender: Any) {
    if let button = sender as? UIButton, let amountString = button.titleLabel?.text {
      if let amount = Int(amountString) {
        paymentContext?.paymentAmount = amount * 100
      }
      
      reloadPaymentButtonContent()
    }
  }
  
  @IBAction func paymentButtonTapped(_ sender: Any) {
    // present Stripe UI
    paymentContext?.presentPaymentMethodsViewController()
  }
  
  @IBAction func payButtonTapped(_ sender: Any) {
    paymentContext?.requestPayment()
  }
  
  // MARK: - private
  
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
  
  private func reloadPaymentButtonContent() {
    guard let paymentAmount = paymentContext?.paymentAmount, paymentAmount > 0 else {
      payButton.isEnabled = false
      return
    }
    
    guard let selectedPaymentMethod = paymentContext?.selectedPaymentMethod else {
      // Show default image, text, and color
      paymentMethodButton.setTitle("Choose payment method", for: .normal)
      paymentMethodButton.setTitleColor(.primaryRedColor, for: .normal)
      payButton.isEnabled = false
      return
    }
    
    // Show selected payment method image, label, and darker color
    payButton.isEnabled = true
    paymentMethodButton.setImage(selectedPaymentMethod.image, for: .normal)
    paymentMethodButton.setTitle("Pay with \(selectedPaymentMethod.label)", for: .normal)
  }
}

extension TopUpViewController: STPPaymentContextDelegate {
  func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
    logger.error(error)
    alertError(error)
  }
  
  func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
    reloadPaymentButtonContent()
  }
  
  func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
    // Create charge using payment result
    let source = paymentResult.source.stripeID
    
    // call api to process payment
    apiTask?.cancel()
    showLoading()
    apiTask = PaymentService.topUpBalance(paymentContext.paymentAmount, stripeSource: source, completion: { (error) in
      completion(error)
    })
  }
  
  func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
    switch status {
    case .success:
      alertMessage(title: "Thank You!",
                   message: "payment has been received",
                   positiveActionButtonTapped: {
                    self.performSegue(withIdentifier: R.segue.topUpViewController.unwindToWallet, sender: nil)
      })
      
      
      break
    case .error:
      // Present error to user
      if let error = error {
        alertError(error)
      }
    case .userCancellation:
      // Reset ride request state
      break
    }
  }
  
  
}
