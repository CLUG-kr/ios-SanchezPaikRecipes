//
//  MainViewController.swift
//  PaikRecipes
//
//  Created by Tars on 7/26/19.
//  Copyright © 2019 sspog. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        // 네비게이션 바 숨기기
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    // 해당 navigationController로 묶인 하위의 뷰들도 다 숨겨지므로 viewWillDisappear에서 다시 나타나게 해주어야 한다.
    override func viewWillDisappear(_ animated: Bool) {
        // 네비게이션 바 숨기기
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
}
