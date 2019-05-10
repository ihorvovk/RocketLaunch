//
//  RocketLaunchListViewController.swift
//  RocketLaunch
//
//  Created by Ihor Vovk on 5/1/19.
//  Copyright © 2019 Ihor Vovk. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import SafariServices
import RealmSwift
import RxRealm

protocol LaunchListViewControllerDelegate: class {
    func launchListViewController(_ controller: LaunchListViewController, didSelectLaunch launch: RocketLaunch)
}

class LaunchListViewController: UIViewController, StoryboardView {
    
    var delegate: LaunchListViewControllerDelegate?
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = refreshControl
    }
    
    func bind(reactor: LaunchListViewReactor) {
        reactor.state.map { $0.searchName }
            .bind(to: searchBar.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.flatMapLatest { Observable.collection(from: $0.launches) }
            .bind(to: tableView.rx.items(cellIdentifier: "rocketLaunch")) { [weak self] (row, launch, cell) in
                guard let `self` = self, let cell = cell as? LaunchTableViewCell else { return }
                cell.fill(rocketLaunch: launch, delegate: self)
                cell.tag = row
            }.disposed(by: disposeBag)
                
        searchBar.rx.text.debounce(0.5, scheduler: MainScheduler.instance).map { Reactor.Action.search($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.rx.prefetchRows.map { Reactor.Action.fetchLaunches(indexes: $0.map { $0.row }) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    
        tableView.rx.willDisplayCell.map { Reactor.Action.fetchLaunches(indexes: [$0.indexPath.row]) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: { [weak self, weak reactor] indexPath in
            guard let `self` = self else { return }
            self.tableView.deselectRow(at: indexPath, animated: false)
            
            if let launch = reactor?.currentState.launches[indexPath.row] {
                self.delegate?.launchListViewController(self, didSelectLaunch: launch)
            }
        }).disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged).map { Reactor.Action.reload }
            .do(onNext: { [weak self] _ in
                self?.refreshControl.endRefreshing()
            }).bind(to: reactor.action).disposed(by: disposeBag)
        
        toggleFavoriteSubject.map { (index, isFavorite) -> Reactor.Action in
            return Reactor.Action.setLaunch(index: index, isFavorite: isFavorite)
        }.bind(to: reactor.action).disposed(by: disposeBag)
    }
    
    // MARK: - Implementation
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    
    private var toggleFavoriteSubject = PublishSubject<(index: Int, isFavorite: Bool)>()
}

extension LaunchListViewController: LaunchTableViewCellDelegate {
    
    func launchTableViewCell(_ cell: LaunchTableViewCell, didToggleFavorite isFavorite: Bool) {
        toggleFavoriteSubject.onNext((index: cell.tag, isFavorite: isFavorite))
    }
}
