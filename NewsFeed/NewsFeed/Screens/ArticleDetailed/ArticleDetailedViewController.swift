//
//  ArticleDetailedViewController.swift
//  NewsFeed
//
//  Created by Роман Плахов on 27/09/2019.
//  Copyright © 2019 Роман Плахов. All rights reserved.
//

import UIKit
import WebKit

class ArticleDetailedViewController: UIViewController {
	private let spinnerTag = 777
	
	private var webView: WKWebView!
	
	private var url: String!
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
	
	convenience init(url: String) {
		self.init()
		
		initiateWebView()
		
		let requestUrl = URL(string: url)!
		let request = URLRequest(url: requestUrl)
		webView.load(request)
		
		startSpinnerAnimation()
	}
	
	private func initiateWebView() {
		let config = WKWebViewConfiguration()
		webView = WKWebView(frame: .zero, configuration: config)
		webView.uiDelegate = self
		webView.navigationDelegate = self
		view.addSubview(webView)
		
		webView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint(item: webView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
		NSLayoutConstraint(item: webView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
		NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
		NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1, constant: 0).isActive = true
	}

	private func startSpinnerAnimation() {
		if view.viewWithTag(spinnerTag) == nil {
			let spinner = UIActivityIndicatorView(style: .gray)
			spinner.center = view.center
			spinner.center.x -= spinner.bounds.size.width
			spinner.startAnimating()
			spinner.tag = spinnerTag
			view.addSubview(spinner)
			
			spinner.translatesAutoresizingMaskIntoConstraints = false
			
			NSLayoutConstraint(item: spinner, attribute: .centerX, relatedBy: .equal, toItem: webView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
			NSLayoutConstraint(item: spinner, attribute: .centerY, relatedBy: .equal, toItem: webView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
		}
	}
	
	private func stopSpinnerAnimation() {
		if let spinner = view.viewWithTag(spinnerTag) {
			spinner.removeFromSuperview()
		}
	}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ArticleDetailedViewController: WKUIDelegate, WKNavigationDelegate {
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		let scrollableSize = CGSize(width: view.frame.size.width, height: webView.scrollView.contentSize.height)
		self.webView?.scrollView.contentSize = scrollableSize
		
		stopSpinnerAnimation()
	}
}
