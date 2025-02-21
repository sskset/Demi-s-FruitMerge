//
//  DroppingFruit.swift
//  FruitMerge
//
//  Created by Shan Ke on 18/2/2025.
//

import SpriteKit

class DroppingFruit: Fruit {
    var aimingLine: DroppingFruitAimingLine?

    init(_ fruitType: FruitType) {
        super.init(fruitType)
    }

    func attachAimingLine(aimingLine: DroppingFruitAimingLine!) {
        self.aimingLine = aimingLine
        self.aimingLine?.position.x = self.position.x
        self.aimingLine?.zPosition = self.zPosition - 1
        self.aimingLine?.isHidden = false
    }

    func deattachAimingLine() {
        self.aimingLine?.isHidden = true
    }

    func move(to x: CGFloat) {
        self.position.x = x
        self.aimingLine?.isHidden = false
        self.aimingLine?.position = self.position
    }

    func drop() {
        self.setupPhysics()
        self.deattachAimingLine()

        NotificationCenter.default.post(name: .dropped, object: nil)

    }

    // Decide when
    func canDrop() -> Bool {
        guard let container = self.parent as? FruitContainerShape
        else { return false }
        return self.position.y <= container.position.y + container.containerSize
            .height / 2
    }

    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Notification.Name {
    static let dropped = Notification.Name("dropped")
}
