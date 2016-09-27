//
//  GroupDisposable.swift
//  Pods
//
//  Created by Yuri Strot on 9/5/16.
//
//

import RxSwift

open class GroupDisposable: Disposable {

	fileprivate var items: [Disposable] = []

	open func dispose() {
		for disposable in items {
			disposable.dispose()
		}
		items = []
	}

	open func add(_ item: Disposable) {
		items.append(item)
	}

}

extension Disposable {
	public func addTo(_ group: GroupDisposable) {
		group.add(self)
	}
}
