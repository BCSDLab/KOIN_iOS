//
//  RoundedNavBarViewController.swift
//  Koin
//
//  Created by 정태훈 on 2020/08/28.
//  Copyright © 2020 정태훈. All rights reserved.
//
import UIKit

class RoundedNavBarViewController: UIViewController , RoundedCornerNavigationBar{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cyan
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
    }
    
    private func setupNavBar(){
        title = "Profile"
        navigationController?.navigationBar.prefersLargeTitles = true
        addRoundedCorner(OnNavigationBar: self.navigationController!.navigationBar, cornerRadius: 20)
    }
    
}

