//
//  TopUpViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 10/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import Stripe

class TopUpViewController: UIViewController {
  @IBOutlet weak var paymentMethodButton: UIButton!
  @IBOutlet weak var payButton: UIButton!
  
  private let customerContext: STPCustomerContext
  private let paymentContext: STPPaymentContext
  
  private var apiTask: URLSessionTask?
  
  // MARK: Init
  
  required init?(coder aDecoder: NSCoder) {
    customerContext = STPCustomerContext(keyProvider: PaymentService())
    paymentContext = STPPaymentContext(customerContext: customerContext)
    paymentContext.configuration.canDeletePaymentMethods = true
    paymentContext.paymentCurrency = "aud"
    
    super.init(coder: aDecoder)
    
    paymentContext.delegate = self
    paymentContext.hostViewController = self
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    payButton.isEnabled = false
  }
  
  
  @IBAction func amountChoosed(_ sender: Any) {
    if let button = sender as? UIButton, let amountString = button.titleLabel?.text {
      if let amount = Int(amountString) {
        paymentContext.paymentAmount = amount * 100
      }
      
      reloadPaymentButtonContent()
    }
  }
  
  @IBAction func paymentButtonTapped(_ sender: Any) {
    // present Stripe UI
    paymentContext.presentPaymentMethodsViewController()
  }
  
  @IBAction func payButtonTapped(_ sender: Any) {
    paymentContext.requestPayment()
  }
  
  private func reloadPaymentButtonContent() {
    guard paymentContext.paymentAmount > 0 else {
      payButton.isEnabled = false
      return
    }
    
    guard let selectedPaymentMethod = paymentContext.selectedPaymentMethod else {
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
    paymentMethodButton.setTitleColor(.stripePrimaryForegroundColor, for: .normal)
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
      flashSuccessMessage("payment has been received, thank you!") { [weak self] (success) in
        self?.perform(segue: StoryboardSegue.Account.fromTopUpToAccount)
      }
      
      break
    case .error:
      // Present error to user
      if let error = error {
        logger.error(error.localizedDescription)
        flashErrorMessage(error.localizedDescription)
      }
    case .userCancellation:
      // Reset ride request state
      break
    }
  }
  
  
}
