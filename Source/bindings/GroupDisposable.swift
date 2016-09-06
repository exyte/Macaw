//
//  GroupDisposable.swift
//  Pods
//
//  Created by Yuri Strot on 9/5/16.
//
//

import RxSwift

public class GroupDisposable: Disposable {

	private var items: [Disposable] = []

	public func dispose() {
		for disposable in items {
			disposable.dispose()
		}
		items = []
	}

	public func add(item: Disposable) {
		items.append(item)
	}

}

extension Disposable {
	public func addTo(group: GroupDisposable) {
		group.add(self)
	}
}
