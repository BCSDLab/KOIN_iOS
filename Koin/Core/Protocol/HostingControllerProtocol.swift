//
//  HostingControllerProtocol.swift
//  Koin
//
//  Created by 홍기정 on 6/1/26.
//

protocol HostingControllerProtocol: AnyObject {
    associatedtype Action

    func execute(action: Action)
}
