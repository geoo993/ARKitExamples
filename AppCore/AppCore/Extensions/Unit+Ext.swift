//
//  Unit+Ext.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 04/02/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import Foundation

public class UnitConverterPace: UnitConverter {
    private let coefficient: Double
    
    public init(coefficient: Double) {
        self.coefficient = coefficient
    }
    
    override public func baseUnitValue(fromValue value: Double) -> Double {
        return reciprocal(value * coefficient)
    }
    
    override public func value(fromBaseUnitValue baseUnitValue: Double) -> Double {
        return reciprocal(baseUnitValue * coefficient)
    }
    
    private func reciprocal(_ value: Double) -> Double {
        guard value != 0 else { return 0 }
        return 1.0 / value
    }
}

public extension UnitSpeed {
    public class var secondsPerMeter: UnitSpeed {
        return UnitSpeed(symbol: "sec/m", converter: UnitConverterPace(coefficient: 1))
    }
    
    public class var minutesPerKilometer: UnitSpeed {
        return UnitSpeed(symbol: "min/km", converter: UnitConverterPace(coefficient: 60.0 / 1000.0))
    }
    
    public class var minutesPerMile: UnitSpeed {
        return UnitSpeed(symbol: "min/mi", converter: UnitConverterPace(coefficient: 60.0 / 1609.34))
    }
}


