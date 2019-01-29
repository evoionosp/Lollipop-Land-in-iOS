//
//  Setting.swift
//  Lollipop Land
//
//  Created by Shubh Patel on 2019-01-29.
//  Copyright © 2019 Shubh Patel. All rights reserved.
//

import SpriteKit

enum PhysicsCategories {
    static let none: UInt32 = 0
    
    static let birdCategory:UInt32 = 0x1 << 0  // =1  (01)
    static let lollipopCategory:UInt32 = 0x1 << 1 // =10  (10)
    static let flowerCategory:UInt32 = 0x1 << 2 // =11  (11)
    static let groundCategory:UInt32 = 0x1 << 3 // =100 (100)
}

enum ZPositions {
    static let background: CGFloat = 0
    static let stick: CGFloat = 3
    static let pop: CGFloat = 4
    static let bird: CGFloat = 4
    static let buttons: CGFloat = 4
}
