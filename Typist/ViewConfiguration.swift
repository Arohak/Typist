//
//  ViewConfiguration.swift
//  Zangi
//
//  Created by Admin on 9/26/18.
//  Copyright © 2018 Zangi Livecom Pte. Ltd. All rights reserved.
//

import Foundation

protocol ViewConfiguration: class {
    
    func setupViewConfiguration()
    func configureViews()
    func buildViewHierarchy()
    func setupConstraints()
}

extension ViewConfiguration {
    
    func setupViewConfiguration() {
        configureViews()
        buildViewHierarchy()
        setupConstraints()
    }
}
