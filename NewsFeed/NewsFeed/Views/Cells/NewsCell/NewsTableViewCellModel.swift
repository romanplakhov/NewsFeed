//
//  NewsTableViewCellModel.swift
//  NewsFeed
//
//  Created by Роман Плахов on 26/09/2019.
//  Copyright © 2019 Роман Плахов. All rights reserved.
//

import Foundation
import RxCocoa

class NewsTableViewCellModel {
	let titleRelay = BehaviorRelay<String>(value: "")
	let descriptionRelay = BehaviorRelay<String>(value: "")
	let dateRelay = BehaviorRelay<Date?>(value: nil)
	let imageURLRelay = BehaviorRelay<String>(value: "")
	
	weak var article: Article? {
		didSet {
			guard let theArticle = article, !theArticle.isInvalidated else {return}
			
			titleRelay.accept(theArticle.title)
			descriptionRelay.accept(theArticle.articleDescription)
			dateRelay.accept(theArticle.parsedDate)
			imageURLRelay.accept(theArticle.urlToImage)
		}
	}
}
