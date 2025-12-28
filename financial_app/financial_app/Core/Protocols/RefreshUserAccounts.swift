//
//  RefreshUserAccounts.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/26.
//

import Combine

protocol RefreshUserAccounts: AnyObject {
    var accountDidChange: PassthroughSubject<Void, Never> { get }
}
