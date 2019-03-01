//
//  TopUpViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 10/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import Stripe

protocol TopUpViewControllerDelegate {
  func didTopUp(topUpViewController: UIViewController)
}

class TopUpViewController: UIViewController {
  @IBOutlet weak var insufficientFundLabel: UILabel!
  @IBOutlet weak var balanceLabel: UILabel!
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var paymentMethodButton: UIButton!
  @IBOutlet weak var payButton: UIButton!
  
  var insufficientFund: Bool = false
  var delegate: TopUpViewControllerDelegate?
  private var paymentContext: STPPaymentContext?
  private var apiTask: URLSessionTask?
  private var amount : Int = 0 {
    didSet {
      amountLabel.text = Double(amount).priceStringWithoutDecimal
      payButton.isEnabled = amount > 0
      paymentContext?.paymentAmount = amount * 100
    }
  }
  
  // MARK: lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let customerContext = STPCustomerContext(keyProvider: PaymentService())
    paymentContext = STPPaymentContext(customerContext: customerContext)
    paymentContext?.configuration.canDeletePaymentMethods = true
    paymentContext?.paymentCurrency = "aud"
    paymentContext?.delegate = self
    paymentContext?.hostViewController = self
    
    navigationController?.navigationBar.applyLightTheme()
    insufficientFundLabel.isHidden = !insufficientFund
    paymentMethodButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    paymentMethodButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
    
    updatePaymentMethodButton()
    
    loadProfile()
  }
  
  // MARK: - user actions
  
  @IBAction func amountChoosed(_ sender: Any) {
    if let button = sender as? UIButton {
      let tag = button.tag
      switch tag {
      case 0:
        amount = 0
      default:
        amount += tag
      }
    }
  }
  
  @IBAction func paymentButtonTapped(_ sender: Any) {
    paymentContext?.presentPaymentMethodsViewController()
  }
  
  @IBAction func payButtonTapped(_ sender: Any) {
    paymentContext?.requestPayment()
  }
  
  // MARK: - API
  
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
        
        self?.balanceLabel.text = user.balance.priceString
      }
    })
  }
  
  // MARK: - private
  private func updatePaymentMethodButton() {
    if let selectedPaymentMethod = paymentContext?.selectedPaymentMethod {
      paymentMethodButton.setImage(selectedPaymentMethod.image, for: .normal)
      paymentMethodButton.setTitle(selectedPaymentMethod.label, for: .normal)
      payButton.isEnabled = amount > 0
    } else {
      paymentMethodButton.setTitle("Add payment method", for: .normal)
      paymentMethodButton.setTitleColor(.primaryRedColor, for: .normal)
      payButton.isEnabled = false
    }
  }
}

extension TopUpViewController: STPPaymentContextDelegate {
  func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
    alertError(error)
  }
  
  func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
    updatePaymentMethodButton()
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
      alertMessage(title: "Your wallet has been credited",
                   message: nil,
                   image: R.image.imgSuccessCheck(),
                   positiveActionButtonTapped: {
                    self.loadProfile()
                    self.delegate?.didTopUp(topUpViewController: self)
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
