//
//  AccountViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 1/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {
    
    @IBOutlet weak var balanceLabel: UILabel!
    
    private var apiTask: URLSessionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadProfile()
    }
    

    @IBAction func unwindToAccount(_ unwindSegue: UIStoryboardSegue) {
        // let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
        
        if unwindSegue.identifier == StoryboardSegue.Account.fromTopUpToAccount.rawValue {
            loadProfile()
        }
    }
    
    private func loadProfile() {
        apiTask?.cancel()
        
        showLoading()
        
        apiTask = UserService().getProfile({[weak self] (result, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    self?.dismissLoading(withMessage: error?.localizedDescription)
                    return
                }
                
                guard let profile = result as? JSON else {
                    self?.dismissLoading(withMessage: L10n.kOtherError)
                    return
                }
                
                self?.dismissLoading()
                let balance = profile["balance"] as! Double
                self?.balanceLabel.text = "Balance \(balance.currencyString)"
            }
        })
    }

}
