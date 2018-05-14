//
//  Protocol.swift
//  tableview
//
//  Created by Алексей  Червон  on 05.01.18.
//  Copyright © 2018 eInternetFunAlexChervon. All rights reserved.
//  // Протокол для манипуляции над плеером из другого контроллера

import Foundation
protocol CurrentTrackDelegate
{
    func Play()
    func Next()
    func Prev()
    func changeTime(value: Double)
}
