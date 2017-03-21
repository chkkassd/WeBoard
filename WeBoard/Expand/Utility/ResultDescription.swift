//
//  ResultDescription.swift
//  WeBoard
//
//  Created by 赛峰 施 on 2017/3/21.
//  Copyright © 2017年 赛峰 施. All rights reserved.
//

import Foundation

///This enumuration describes the result of all situation
enum Result<T> {
    case success(T)
    case failure(Error)
}

extension Result {
    func flatMap<U>(_ transform: (T) -> Result<U>) -> Result<U> {
        switch self {
        case .success(let v):
            return transform(v)
        case .failure(let e):
            return .failure(e)
        }
    }
}
