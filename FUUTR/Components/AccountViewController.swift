//
//  AccountViewController.swift
//  FUUTR
//
//  Created by Chris Chen on 1/11/18.
//  Copyright © 2018 FUUTR. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import FBSDKLoginKit
import IHKeyboardAvoiding
import Kingfisher

class AccountViewController: UIViewController, Coordinatable {
    var cooridnator: Coordinator?
    
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var avatarEditButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var passwordButton: UIButton!
    @IBOutlet weak var avatarSelectionView: AvatarSelectionView! {
        didSet {
            avatarSelectionView.onDismiss = {
                self.toggleAvatarSelectionView(on: false)
            }
            
            avatarSelectionView.onSelectPresetAvatar = { presetAvatar in
                self.avatarImageView.image = presetAvatar
                self.avatarChanged = true
                self.toggleAvatarSelectionView(on: false)
            }
            
            avatarSelectionView.onCamera = {
                self.performSegue(withIdentifier: R.segue.accountViewController.showPhotoShoot, sender: nil)
            }
        }
    }
    @IBOutlet weak var avatarSelectionViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var avatarSelectionViewTopConstraint: NSLayoutConstraint!
    
    private var apiTask: URLSessionTask?
    private var user: User? {
        didSet {
            toggleEditing(false)
            
            if let user = user {
                populateUserProfile(user, editing: false)
            }
        }
    }
    private var avatarChanged: Bool = false
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.applyLightTheme()
        
        toggleEditing(false)
        loadProfile()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        KeyboardAvoiding.avoidingView = stackView
    }
    
    override func viewDidLayoutSubviews() {
        avatarImageView.layoutCircularMask()
        
        avatarEditButton.layoutCircularMask()
        
        avatarSelectionViewHeightContraint.constant = view.bounds.size.height
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController,
            let mobileRequestCodeViewController = navigationController.topViewController as? MobileRequestCodeViewController {
            mobileRequestCodeViewController.action = .updatePhone
        }
            
        else if let navigationController = segue.destination as? UINavigationController,
            let updatePasswordViewController = navigationController.topViewController as? UpdatePasswordViewController,
            let hasPassword = user?.hasPassword {
            updatePasswordViewController.hasPassword = hasPassword
        }
            
        else if let navigationController = segue.destination as? UINavigationController,
            let photoShootViewController = navigationController.topViewController as? PhotoShootViewController {
            photoShootViewController.action = .userAvatar
            photoShootViewController.title = "Account Avatar Photo"
        }
    }
    
    // MARK: - user actions
    
    @IBAction func unwindToSettings(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        
        if let photoShootViewController = sourceViewController as? PhotoShootViewController,
            let photo = photoShootViewController.photo {
            self.avatarImageView.image = photo
            self.avatarChanged = true
            self.toggleAvatarSelectionView(on: false)
        }
        else {
            loadProfile()
        }
    }
    
    @objc func unwindToHome() {
        performSegue(withIdentifier: R.segue.accountViewController.unwindToHome, sender: nil)
    }
    
    @objc func cancelEditing() {
        toggleEditing(false)
        toggleAvatarSelectionView(on: false)
    }
    
    @objc func startEditing() {
        toggleEditing(true)
    }
    
    @objc func saveEditing() {
        toggleAvatarSelectionView(on: false)
        
        var profile: JSON = [:]
        
        if let name =  nameTextField.text, name.count > 0 && name != "+ Add your name" {
            profile["displayName"] = name
        }
        
        if profile.count > 0 {
            apiTask?.cancel()
            
            showLoading()
            
            apiTask = UserService.updateProfile(profile,
                                                avatar: avatarChanged ? avatarImageView.image : nil,
                                                completion: { [weak self] (error) in
                                                    DispatchQueue.main.async {
                                                        
                                                        self?.dismissLoading()
                                                        
                                                        guard error == nil else {
                                                            self?.alertError(error!)
                                                            return
                                                        }
                                                        
                                                        self?.avatarChanged = false
                                                        
                                                        self?.loadProfile()
                                                    }
            })
        }
        else {
            toggleEditing(false)
        }
    }
    
    @IBAction func editAvatar(_ sender: Any) {
        toggleAvatarSelectionView(on: true)
    }
    
    @IBAction func editingNameDidBegin(_ sender: Any) {
        nameTextField.textColor = UIColor.primaryGreyColor
        
        if nameTextField.text == "+ Add your name" {
            nameTextField.text = ""
        }
    }
    
    
    @IBAction func signOut() {
        _ = AuthService.logout { (error) in
            if error != nil {
                logger.error(error?.localizedDescription)
            }
            
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: {
                    if let mainCoodinator = self.cooridnator as? MainCoordinator {
                        mainCoodinator.userDidSignOut()
                    }
                })
            }
        }
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
                
                self?.user = user
            }
        })
    }
    
    // MARK: - private
    private func toggleEditing(_ on: Bool) {
        if on {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                               target: self,
                                                               action: #selector(cancelEditing))
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                                target: self,
                                                                action: #selector(saveEditing))
            
            nameTextField.isEnabled = true
            emailButton.isEnabled = true
            phoneButton.isEnabled = false
            passwordButton.isEnabled = true
            
            avatarEditButton.isHidden = false
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.icCloseDarkGray16(),
                                                               style: .plain,
                                                               target: self,
                                                               action: #selector(unwindToHome))
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                                target: self,
                                                                action: #selector(startEditing))
            
            nameTextField.isEnabled = false
            emailButton.isEnabled = false
            phoneButton.isEnabled = false
            passwordButton.isEnabled = false
            
            avatarEditButton.isHidden = true
        }
        
        if let user = user {
            populateUserProfile(user, editing: on)
        }
    }
    
    private func populateUserProfile(_ user: User, editing: Bool) {
        if let photo = user.photo, let avatarURL = URL(string: photo) {
            avatarImageView.kf.setImage(with: avatarURL)
        }
        
        if let displayName = user.displayName, displayName.count > 0 {
            nameTextField.textColor = UIColor.primaryGreyColor
            nameTextField.placeholder = "e.g. Charlotte Johnston"
            nameTextField.text = displayName
        }
        else {
            nameTextField.textColor = UIColor.primaryRedColor
            nameTextField.placeholder = "e.g. Charlotte Johnston"
            nameTextField.text = "+ Add your name"
        }
        nameTextField.isEnabled = editing
        
        if let email = user.email, email.count > 0 {
            emailButton.setTitleColor(UIColor.primaryGreyColor, for: .normal)
            emailButton.setTitle(email, for: .normal)
            emailButton.isEnabled = editing
        }
        else {
            emailButton.setTitleColor(UIColor.primaryRedColor, for: .normal)
            emailButton.setTitle("+ Add an email", for: .normal)
            emailButton.isEnabled = true
        }
        
        if user.formattedPhoneNumber.count > 0 {
            phoneButton.setTitleColor(UIColor.primaryGreyColor, for: .normal)
            phoneButton.setTitle(user.formattedPhoneNumber, for: .normal)
            phoneButton.isEnabled = editing
        }
        else {
            phoneButton.setTitleColor(UIColor.primaryRedColor, for: .normal)
            phoneButton.setTitle("+ Add a phone", for: .normal)
            phoneButton.isEnabled = true
        }
        
        if let hasPassword = user.hasPassword, hasPassword {
            passwordButton.setTitleColor(UIColor.primaryGreyColor, for: .normal)
            passwordButton.setTitle("∙∙∙∙∙∙∙∙", for: .normal)
            passwordButton.isEnabled = editing
        }
        else {
            passwordButton.setTitleColor(UIColor.primaryRedColor, for: .normal)
            passwordButton.setTitle("+ Add a password", for: .normal)
            passwordButton.isEnabled = true
        }
    }
    
    private func toggleAvatarSelectionView(on: Bool) {
        if on {
            avatarSelectionViewTopConstraint.constant = avatarSelectionView.bounds.size.height
            nameTextField.resignFirstResponder()
        } else {
            avatarSelectionViewTopConstraint.constant = 0
        }
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}
