//
//  LaunchInfoViewController.swift
//  RocketLaunch
//
//  Created by Ihor Vovk on 5/5/19.
//  Copyright © 2019 Ihor Vovk. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import WebKit

class LaunchInfoViewController: UIViewController, StoryboardView {
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
    }
    
    func bind(reactor: LaunchInfoViewReactor) {
        reactor.state.subscribe(onNext: { [weak self] state in
            if let infoURL = state.infoURL, self?.webView.url == nil {
                self?.activityIndicator.startAnimating()
                
                let urlRequest = URLRequest(url: infoURL)
                self?.webView.load(urlRequest)
            }
            
            self?.favoriteBarButtonItem.image = UIImage(named: state.isFavorite ? "blue_star_full" : "blue_star_empty")
        }).disposed(by: disposeBag)
        
        favoriteBarButtonItem.rx.tap.map { Reactor.Action.toggleFavorite }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Implementation
    
    @IBOutlet private weak var favoriteBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction private func done(sender: Any) {
        dismiss(animated: true)
    }
}

extension LaunchInfoViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
}
