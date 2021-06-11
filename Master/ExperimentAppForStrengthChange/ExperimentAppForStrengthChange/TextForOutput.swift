//
//  TextForOutput.swift
//  Connector_iPhone_And_Arduino
//
//  Created by 日高拓真 on 2020/11/22.
//

import Foundation

class TextForOutput: ObservableObject{
    @Published var ListOfTextForOutput: [String]
    
    init(first_text: String) {
        ListOfTextForOutput = [first_text]
    }
    init() {
        ListOfTextForOutput = []
    }
    init(first_list_of_text: [String]){
        ListOfTextForOutput = first_list_of_text
    }
}

class Printer{
    static private var text_for_output = TextForOutput()
    
    static func set_text_for_output(target_text: TextForOutput){
        text_for_output = target_text
    }
    
    static func print_to_List(print_list_of_string: [String]){
        Printer.text_for_output.ListOfTextForOutput.append(contentsOf: print_list_of_string)
    }

    static func print_to_List(print_string: String){
        Printer.text_for_output.ListOfTextForOutput.append(print_string)
    }
    
    static func get_list_of_text()->[String]{
        return text_for_output.ListOfTextForOutput
    }
    
    static func reset_list_of_text(){
        return text_for_output.ListOfTextForOutput = []
    }
}
