//
//  ReportIssueViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 17/2/19.
//  Copyright © 2019 FUUTR. All rights reserved.
//

import UIKit

enum IssueType: String {
  case unlock, damage, parking, other
  
  var title: String {
    switch self {
    case .unlock:
      return "Lock/Unlock"
    case .damage:
      return "Damaged"
    case .parking:
      return "Illegal Parking"
    case .other:
      return "Other Issue"
    }
  }
}

class ReportIssueViewController: UIViewController {
  
  var ride: Ride?
  var vehicle: Vehicle?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.applyLightTheme()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let formViewController = segue.destination as? IssueFormViewController,
      let issueType = sender as? IssueType {
      formViewController.issueType = issueType
      formViewController.ride = ride
      formViewController.vehicle = vehicle
    }
  }
  
  
  @IBAction func close(_ sender:Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func unlockIssue(_ sender: Any) {
    performSegue(withIdentifier: R.segue.reportIssueViewController.showForm, sender: IssueType.unlock)
  }
  @IBAction func damageIssue(_ sender: Any) {
    performSegue(withIdentifier: R.segue.reportIssueViewController.showForm, sender: IssueType.damage)
  }
  @IBAction func parkingIssue(_ sender: Any) {
    performSegue(withIdentifier: R.segue.reportIssueViewController.showForm, sender: IssueType.parking)
  }
  @IBAction func otherIssue(_ sender: Any) {
    performSegue(withIdentifier: R.segue.reportIssueViewController.showForm, sender: IssueType.other)
  }
}
