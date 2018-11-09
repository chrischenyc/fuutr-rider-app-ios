//
//  ChoosePaymentMethodsViewController.swift
//  OTGRider
//
//  Created by Chris Chen on 10/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import UIKit

class ChoosePaymentMethodsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var savedPaymentMethods: [Any] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: .zero)
    }

}

extension ChoosePaymentMethodsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedPaymentMethods.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < savedPaymentMethods.count {
            let savedPaymentMethod = savedPaymentMethods[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "SavedCardCell", for: indexPath)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewCardCell", for: indexPath)
        return cell
    }
}

extension ChoosePaymentMethodsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < savedPaymentMethods.count {
            let savedPaymentMethod = savedPaymentMethods[indexPath.row]
            // rewind to top up screen with selected saved card info
        }
        else {
            perform(segue: StoryboardSegue.Account.fromChoosePaymentMethodsToNewCard)
        }
    }
}
