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
import PagedArray

protocol LaunchListViewControllerDelegate: class {
    func launchListViewController(_ controller: LaunchListViewController, didSelectLaunch launch: RocketLaunch)
}

class LaunchListViewController: UIViewController, StoryboardView {
    
    var delegate: LaunchListViewControllerDelegate?
    var disposeBag = DisposeBag()
    
    func bind(reactor: LaunchListViewReactor) {
        reactor.state.map { $0.searchName }
            .bind(to: searchBar.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.launches ?? PagedArray(count: 0, pageSize: 0) }
            .bind(to: tableView.rx.items(cellIdentifier: "rocketLaunch")) { [weak self] (row, launch, cell) in
                guard let `self` = self, let cell = cell as? LaunchTableViewCell else { return }
                cell.fill(rocketLaunch: launch, delegate: self)
                cell.tag = row
            }.disposed(by: disposeBag)
                
        searchBar.rx.text.map { Reactor.Action.search($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.rx.prefetchRows.map { Reactor.Action.prefetchLaunches(indexPaths: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    
        tableView.rx.willDisplayCell.map { Reactor.Action.prefetchLaunches(indexPaths: [$0.indexPath]) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: { [weak self, weak reactor] indexPath in
            guard let `self` = self else { return }
            self.tableView.deselectRow(at: indexPath, animated: false)
            
            if let launch = reactor?.currentState.launches?[indexPath.row] {
                self.delegate?.launchListViewController(self, didSelectLaunch: launch)
            }
        }).disposed(by: disposeBag)
        
        toggleFavoriteSubject.map { (index, isFavorite) -> Reactor.Action in
            return Reactor.Action.setLaunch(index: index, isFavorite: isFavorite)
        }.bind(to: reactor.action).disposed(by: disposeBag)
    }
    
    // MARK: - Implementation
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var toggleFavoriteSubject = PublishSubject<(index: Int, isFavorite: Bool)>()
}

extension LaunchListViewController: LaunchTableViewCellDelegate {
    
    func launchTableViewCell(_ cell: LaunchTableViewCell, didToggleFavorite isFavorite: Bool) {
        toggleFavoriteSubject.onNext((index: cell.tag, isFavorite: isFavorite))
    }
}
