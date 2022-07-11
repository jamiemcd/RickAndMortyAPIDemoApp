//
//  UINavigationControllerExtension.swift
//  RickAndMortyAPIDemo
//
//  Created by Jamie McDaniel on 7/10/22.
//

import UIKit

extension UINavigationController {
    open override func viewWillLayoutSubviews() {
      super.viewWillLayoutSubviews()
      navigationBar.topItem?.backButtonDisplayMode = .minimal
    }
}
