//
//  NewsSectionModel.swift
//  NewsFeed
//
//  Created by Роман Плахов on 26/09/2019.
//  Copyright © 2019 Роман Плахов. All rights reserved.
//

import Foundation
import RxDataSources

enum NewsTableSectionModelItem {
	case newsItem(Article)
	case errorItem
}

enum NewsTableSectionModel {
	case newsSection(content: [NewsTableSectionModelItem], header: String?, footer: String?)
}

extension NewsTableSectionModel: SectionModelType {
	typealias Item = NewsTableSectionModelItem
	
	var footer: String? {
		switch self {
		case let .newsSection(_, _, footer): return footer
		}
	}
	
	var header: String? {
		switch self {
		case let .newsSection(_, header, _): return header
		}
	}
	
	var items: [Item] {
		switch self {
		case let .newsSection(content, _, _): return content
		}
	}
	
	init(original: NewsTableSectionModel, items: [Item]) {
		switch original {
		case let .newsSection(_, header, footer):
			self = .newsSection(content: items, header: header, footer: footer)
		}
	}
}
