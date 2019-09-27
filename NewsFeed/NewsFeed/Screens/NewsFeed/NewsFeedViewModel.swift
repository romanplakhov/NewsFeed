//
//  NewsFeedViewModel.swift
//  NewsFeed
//
//  Created by Роман Плахов on 25/09/2019.
//  Copyright © 2019 Роман Плахов. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm
import Moya
import SwiftyJSON


class NewsFeedViewModel {
	static let maximumPagesCount = 5
	static let newsPerPage = 20
	
	let sections = BehaviorSubject<[NewsTableSectionModel]>(value: [])
	
	let needToRequestMoreNewsForCurrentCount = PublishSubject<Int>()
	let refreshingRequired = PublishSubject<Void>()
	let regreshingCompleted = PublishSubject<Void>()
	let fetchingIsInProgress = PublishRelay<Bool>()
	
	private let errorHasOccuredWhileLoading = BehaviorRelay<Bool>(value: false)
	
	private let realm = try! Realm()
	
	private let newsService = MoyaProvider<MoyaNewsService>()
	
	private let bag = DisposeBag()

	
	init() {
		Observable<Bool>.just(realm.objects(Article.self).count==0)
			.filter{$0}
			.subscribe(onNext: {[unowned self] _ in
				self.requestNews(for: 1)
			}).disposed(by: bag)
		
		Observable.combineLatest(errorHasOccuredWhileLoading.asObservable(), Observable.collection(from: realm.objects(Article.self)))
			.map {
				isErrorOccured, articles -> [NewsTableSectionModel] in
				var sectionItems: [NewsTableSectionModelItem] = articles.map{$0}
					.map {article in
						return NewsTableSectionModelItem.newsItem(article)
				}
				
				if isErrorOccured {
					sectionItems.append(NewsTableSectionModelItem.errorItem)
				}
				
				
				return [NewsTableSectionModel.newsSection(content: sectionItems, header: nil, footer: nil)]
			}.bind(to: sections)
			.disposed(by: bag)
		
		
		needToRequestMoreNewsForCurrentCount.subscribe(onNext: {[unowned self] currentLoadedNewsCount in
			if currentLoadedNewsCount == NewsFeedViewModel.maximumPagesCount*NewsFeedViewModel.newsPerPage {
				return
			}
			
			let pageToLoad = Float(currentLoadedNewsCount).rounded(.up)/Float(NewsFeedViewModel.newsPerPage).rounded(.up) + 1
			
			self.requestNews(for: Int(pageToLoad.rounded(.up)))
		}).disposed(by: bag)
		
		refreshingRequired.subscribe(onNext: {
			self.requestNews(for: 1, cacheClearingRequired: true)
		}).disposed(by: bag)
		
	}
	
	private func requestNews(for page: Int, cacheClearingRequired: Bool = false) {
		fetchingIsInProgress.accept(true)
		//self.errorHasOccuredWhileLoading.accept(false)
		newsService.rx.request(.getNews(page: page)).subscribe(onSuccess: {[unowned self] response in
			if let json = try? JSON(data: response.data) {
				
				let allCachedArticles = self.realm.objects(Article.self)
				try? self.realm.write {
					if cacheClearingRequired {
						self.realm.delete(allCachedArticles)
					}
					for jsonArticle in json["articles"] {
						self.realm.add(Article.from(jsonArticle.1), update: .all)
					}
				}
				self.regreshingCompleted.onNext(Void())
				self.fetchingIsInProgress.accept(false)
				self.errorHasOccuredWhileLoading.accept(false)
				print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0])
			}
		}, onError: {[unowned self] error in
			if cacheClearingRequired {
				let allCachedArticles = self.realm.objects(Article.self)
				try? self.realm.write {
					if cacheClearingRequired {
						self.realm.delete(allCachedArticles)
					}
				}
			}
			self.regreshingCompleted.onNext(Void())
			self.fetchingIsInProgress.accept(false)
			self.errorHasOccuredWhileLoading.accept(true)
		}).disposed(by: bag)
	}
}
