//
//  Conditions.swift
//  ExperimentAppForStrengthChange
//
//  Created by 日高拓真 on 2021/01/08.
//

import Foundation

public class ConditionItem<T>{
    private var name: String
    private var value: T
    
    init(name: String, value: T) {
        self.name = name
        self.value = value
    }
    
    func getName() -> String {
        return self.name
    }
    
    func getValue() -> T {
        return self.value
    }
}

class Condition<T: Equatable>{
    var ConditionItems: Array<ConditionItem<T>> = []
    var ConditionName: String = ""
    
    init() {
        
    }
        
    func getItemArray() -> Array<ConditionItem<T>>{
        return ConditionItems
    }
    
    func getConditionName() -> String{
        return ConditionName
    }
    
    func getValueToName(value: T) -> String{
        for item in ConditionItems{
            if(item.getValue() == value){
                return item.getName()
            }
        }
        return ""
    }
}

class IncreasePin: Condition<String>{
    override init() {
        super.init()
        self.ConditionItems.append(ConditionItem(name: "NAIL", value: "10"))
        self.ConditionItems.append(ConditionItem(name: "FINGER", value: "9"))
        self.ConditionItems.append(ConditionItem(name: "WRIST", value: "6"))
        self.ConditionName = "IncreasingPin"
    }
}

class DecreasePin: Condition<String>{
    override init() {
        super.init()
        self.ConditionItems.append(ConditionItem(name: "NAIL", value: "10"))
        self.ConditionItems.append(ConditionItem(name: "FINGER", value: "9"))
        self.ConditionItems.append(ConditionItem(name: "WRIST", value: "6"))
        self.ConditionName = "DecreasingPin"
    }
}

class VibrationDuration: Condition<String>{
    override init() {
        super.init()
        self.ConditionItems.append(ConditionItem(name: "2000", value: "2000"))
        self.ConditionItems.append(ConditionItem(name: "1500", value: "1500"))
        self.ConditionItems.append(ConditionItem(name: "1000", value: "1000"))
        self.ConditionItems.append(ConditionItem(name: "500", value: "500"))
        self.ConditionName = "VibrationDurationMs"
    }
}

class VibrationDirection: Condition<String>{
    override init() {
        super.init()
        self.ConditionItems.append(ConditionItem(name: "FINGER->WRIST", value: "方向1"))
        self.ConditionItems.append(ConditionItem(name: "WRIST->FINGER", value: "方向2"))
        self.ConditionItems.append(ConditionItem(name: "分からない", value: "分からない"))
        self.ConditionName = "Direction"
    }
}

class VibrationOrder: Condition<String>{
    override init(){
        super.init()
        self.ConditionItems.append(ConditionItem(name: "WRIST,NAIL", value:"1"))
        self.ConditionItems.append(ConditionItem(name: "NAIL,WRIST", value:"2"))
        self.ConditionItems.append(ConditionItem(name: "WRIST,FINGER", value:"3"))
        self.ConditionItems.append(ConditionItem(name: "FINGER,WRIST", value:"4"))
        self.ConditionItems.append(ConditionItem(name: "FINGER,NAIL", value:"5"))
        self.ConditionItems.append(ConditionItem(name: "NAIL,FINGER", value:"6"))
        self.ConditionName = "First,Second"
    }
    
    func isMuchItem(vibration_position: String, item: ConditionItem<String>) -> Bool{
        if(vibration_position=="1"){
            return item.getValue() == "1" || item.getValue() == "2"
        }else if(vibration_position=="2"){
            return item.getValue() == "3" || item.getValue() == "4"
        }else if(vibration_position=="3"){
            return item.getValue() == "5" || item.getValue() == "6"
        }
        return false
    }
}

class Pin1: Condition<String>{
    override init() {
        super.init()
        self.ConditionItems.append(ConditionItem(name: "NAIL", value: "10"))
        self.ConditionItems.append(ConditionItem(name: "FINGER", value: "9"))
        self.ConditionItems.append(ConditionItem(name: "WRIST", value: "6"))
        self.ConditionName = "Pin1"
    }
}

class Pin1VibrationStrength: Condition<String>{
    override init() {
        super.init()
        self.ConditionItems.append(ConditionItem(name: "255", value: "255"))
        self.ConditionName = "Pin1VibrationStrength"
    }
}

class Pin2: Condition<String>{
    override init() {
        super.init()
        self.ConditionItems.append(ConditionItem(name: "NAIL", value: "10"))
        self.ConditionItems.append(ConditionItem(name: "FINGER", value: "9"))
        self.ConditionItems.append(ConditionItem(name: "WRIST", value: "6"))
        self.ConditionName = "Pin2"
    }
}

class Pin2VibrationStrength: Condition<String>{
    override init() {
        super.init()
        self.ConditionItems.append(ConditionItem(name: "255", value: "255"))
        self.ConditionName = "Pin2VibrationStrength"
    }
}
