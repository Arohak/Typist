//
//  ModernToolbarContainer.swift
//  Zangi
//
//  Created by Admin on 9/26/18.
//  Copyright © 2018 Zangi Livecom Pte. Ltd. All rights reserved.
//

import UIKit

protocol ModernToolbarContainerProtocol: class {
    var inset: CGFloat  { get }
    var toolbarHeight: CGFloat { get }
}

extension ModernToolbarContainer {
    public enum ToolbarActionType {
        case add
        case smile
    }
    
    public enum ToolbarType {
        case main(Bool)
        case add(Bool)
        case search(Bool)
        case more(Bool)
    }
}

public class ModernToolbarContainer {
    var delegate: ModernToolbarContainerProtocol!
    var bottom: NSLayoutConstraint!
    var heightConstraint: NSLayoutConstraint!

    lazy var toolbarView: ToolbarView = {
        let view = ToolbarView.newAutoLayout()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var toolbarActionsView: ToolbarActionsView = {
        let view = ToolbarActionsView.newAutoLayout()
        view.backgroundColor = .white
        view.isHidden = true
        return view
    }()
    
    lazy var stickersParentView: StickersParentView = {
        let view = StickersParentView.newAutoLayout()
        view.backgroundColor = .red
        return view
    }()
    
    lazy var galleryView: GalleryView = {
        let view = GalleryView.newAutoLayout()
        view.backgroundColor = .blue
        view.isHidden = true
        return view
    }()

    lazy var gifView: GifView = {
        let view = GifView.newAutoLayout()
        view.backgroundColor = .orange
        view.isHidden = true
        return view
    }()
    
    init(delegate: ModernToolbarContainerProtocol) {
        self.delegate = delegate
        setupViewConfiguration()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - ViewConfiguration -
extension ModernToolbarContainer: ViewConfiguration {
    private var vc: UIViewController {
        return (delegate as! ModernToolbarController).vc
    }
    
    func configureViews() {

    }
    
    func buildViewHierarchy() {
        vc.view.addSubview(toolbarView)
        vc.view.addSubview(toolbarActionsView)
        vc.view.addSubview(stickersParentView)
        vc.view.addSubview(galleryView)
        vc.view.addSubview(gifView)
    }
    
    func setupConstraints() {
        let inset = delegate.inset
        let height = delegate.toolbarHeight

        toolbarView.autoPinEdge(toSuperviewEdge: .left)
        toolbarView.autoPinEdge(toSuperviewEdge: .right)
        heightConstraint = toolbarView.autoSetDimension(.height, toSize: height)
        bottom = NSLayoutConstraint(item: vc.bottomLayoutGuide,
                                    attribute: .top,
                                    relatedBy: .equal,
                                    toItem: toolbarView,
                                    attribute: .bottom,
                                    multiplier: 1,
                                    constant: 0)
        vc.view.addConstraint(bottom)
        
        toolbarActionsView.autoPinEdge(toSuperviewEdge: .left, withInset: inset)
        toolbarActionsView.autoPinEdge(toSuperviewEdge: .right, withInset: inset)
        toolbarActionsView.autoSetDimension(.height, toSize: height)
        
        stickersParentView.autoPinEdge(.top, to: .bottom, of: toolbarView)
        stickersParentView.autoPinEdge(toSuperviewEdge: .left)
        stickersParentView.autoPinEdge(toSuperviewEdge: .right)
        stickersParentView.autoPinEdge(toSuperviewEdge: .bottom)
        
        galleryView.autoPinEdge(.top, to: .bottom, of: toolbarView)
        galleryView.autoPinEdge(toSuperviewEdge: .left)
        galleryView.autoPinEdge(toSuperviewEdge: .right)
        galleryView.autoPinEdge(toSuperviewEdge: .bottom)

        gifView.autoPinEdge(.bottom, to: .top, of: toolbarView)
        gifView.autoPinEdge(toSuperviewEdge: .left)
        gifView.autoPinEdge(toSuperviewEdge: .right)
        gifView.autoSetDimension(.height, toSize: height*2)
    }
}
