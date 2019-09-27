//
//  NewsFeedViewController.swift
//  NewsFeed
//
//  Created by Роман Плахов on 25/09/2019.
//  Copyright © 2019 Роман Плахов. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import RxCocoa

class NewsFeedViewController: UIViewController {
	let newsCellReuseIdentifier = "NewsTableViewCell"
	let errorCellReuseIdentifier = "ConnectionErrorTableViewCell"

	@IBOutlet weak var tableView: UITableView!
	var bottomSpinner: UIActivityIndicatorView!
	
	let viewModel = NewsFeedViewModel()
	
	let bag = DisposeBag()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "News"

		tableView.register(UINib(nibName: newsCellReuseIdentifier, bundle: Bundle.main), forCellReuseIdentifier: newsCellReuseIdentifier)
		tableView.register(UINib(nibName: errorCellReuseIdentifier, bundle: Bundle.main), forCellReuseIdentifier: errorCellReuseIdentifier)
		
		tableView.delegate = self
		
		let refreshControl = UIRefreshControl()
		tableView.refreshControl = refreshControl
		refreshControl.addTarget(self, action: #selector(onRefreshingRequires(_:)), for: .valueChanged)
		
		bottomSpinner = UIActivityIndicatorView(style: .gray)
		bottomSpinner.startAnimating()
		bottomSpinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
		
		viewModel.fetchingIsInProgress
			.subscribe(onNext: {[unowned self] isSpinnerRequired in
				if isSpinnerRequired {
					self.tableView.tableFooterView = self.bottomSpinner
				} else {
					self.tableView.tableFooterView = UIView()
				}
				
			})
			//.bind(to: tableView.tableFooterView!.rx.isHidden)
			.disposed(by: bag)
		
		let dataSource = RxTableViewSectionedReloadDataSource<NewsTableSectionModel>(configureCell: {[unowned self] dataSource, tableView, indexPath, model in
			
			switch model {
			case .newsItem(let article):
				guard let cell = tableView.dequeueReusableCell(withIdentifier: self.newsCellReuseIdentifier) as? NewsTableViewCell else {return UITableViewCell()}
				let viewModel = NewsTableViewCellModel()
				cell.viewModel = viewModel
				viewModel.article = article
				
				return cell
			case .errorItem:
				guard let cell = tableView.dequeueReusableCell(withIdentifier: self.errorCellReuseIdentifier) as? ConnectionErrorTableViewCell else {return UITableViewCell()}
				let viewModel = ConnectionErrorTableViewCellModel(retryAction: {self.viewModel.needToRequestMoreNewsForCurrentCount.onNext(self.tableView.numberOfRows(inSection: 0)-1)})
				cell.viewModel = viewModel
				
				return cell
			}
		})
		
		viewModel.sections
			.bind(to: tableView.rx.items(dataSource: dataSource))
			.disposed(by: bag)
		
		tableView.rx.itemSelected.subscribe(onNext: {[unowned self] indexPath in
			self.tableView.deselectRow(at: indexPath, animated: true)
			
			let cell = self.tableView.cellForRow(at: indexPath)
			
			if let newsCell = cell as? NewsTableViewCell {
				let urlToGo = newsCell.viewModel.article!.url
				self.navigationController?.pushViewController(ArticleDetailedViewController(url: urlToGo), animated: true)
			}
		})
		
		Observable.combineLatest(tableView.rx.willDisplayCell, tableView.rx.didEndDisplayingCell,viewModel.fetchingIsInProgress)
			.filter{_,_,isFetchingInProgress in
				return !isFetchingInProgress
			}
			.subscribe(onNext: {[unowned self] willDisplayCellEvent, didEndDisplayingCellEvent, _ in
				let numberOfRows = self.tableView.numberOfRows(inSection: 0)
				guard numberOfRows != 0 else {return}
				
				let appearedRowNumber = willDisplayCellEvent.indexPath.row
				let disappearedRowNumber = didEndDisplayingCellEvent.indexPath.row
				
				if appearedRowNumber == numberOfRows - 5 ,
					appearedRowNumber > disappearedRowNumber {
					print("The case!")
					self.viewModel.needToRequestMoreNewsForCurrentCount.onNext(numberOfRows)
				}
		}).disposed(by: bag)
		
		viewModel.regreshingCompleted.subscribe(onNext: {[unowned self] in
			self.tableView.refreshControl?.endRefreshing()
		}).disposed(by: bag)
		
        // Do any additional setup after loading the view.
    }

	
	@objc private func onRefreshingRequires(_ sender: AnyObject) {
		viewModel.refreshingRequired.onNext(Void())
	}
}

extension NewsFeedViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 200
	}
}
