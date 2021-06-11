//
//  Experiment.swift
//  Connector_iPhone_And_Arduino
//
//  Created by 日高拓真 on 2020/12/06.
//

import Foundation

public class Experiment{
    static private var parameters:[[String:String]] = []
    static private var result_experiment:[[String:String]] = []
    static private var result_experiment_all:[[String:String]] = []
    static private var port_for_send_to_Arduino: SerialController?
    static private var now_parameter:[[String:String]] = []
    static private var increase_pin_condition:IncreasePin = IncreasePin()
    static private var decrease_pin_condition:DecreasePin = DecreasePin()
    static private var pin1_condition:Pin1 = Pin1()
    static private var pin1_vibration_strength_condition:Pin1VibrationStrength = Pin1VibrationStrength()
    static private var pin2_condition:Pin2 = Pin2()
    static private var pin2_vibration_strength_condition:Pin2VibrationStrength = Pin2VibrationStrength()
    static private var vibration_duration_condition:VibrationDuration = VibrationDuration()
    static private var vibration_direction_condition: VibrationDirection = VibrationDirection()
    static private var answer_key: String = "answer"
    static private var taskNum_key: String = "TaskNum, TrialNum"
//    回答ボタンを押してから、もう一度回答ボタンを押すまでの時間（振動提示時間を含む）
    static private var time_key: String = "time(s)"
    
    static func Start(vibration_duration: String){
        port_for_send_to_Arduino = SerialController.get_Port()
        
        parameters = Experiment.MakeParameter(vibration_duration: vibration_duration)
        parameters.shuffle()
        result_experiment = []
    }
    
    static func MakeParameter(vibration_duration: String) -> [[String:String]]{
        var parameters: [[String:String]] = []
        
        for increase_pin in increase_pin_condition.getItemArray(){
            for decrease_pin in decrease_pin_condition.getItemArray(){
                if(increase_pin.getName() != decrease_pin.getName()){
                    parameters.append([
                                        increase_pin_condition.getConditionName():increase_pin.getValue(),
                                        decrease_pin_condition.getConditionName():decrease_pin.getValue(),
                                        vibration_duration_condition.getConditionName():vibration_duration
                    ])
                }
            }
        }
        
        var not_loop_item: [String] = []
        
        for pin1 in pin1_condition.getItemArray(){
            not_loop_item.append(pin1.getName())
            for pin1_vibration_strength in pin1_vibration_strength_condition.getItemArray(){
                for pin2 in pin2_condition.getItemArray(){
                    for pin2_vibration_strength in pin2_vibration_strength_condition.getItemArray(){
                        if (!not_loop_item.contains(pin2.getName())) {
                            parameters.append([
                                pin1_condition.getConditionName():pin1.getValue(),
                                pin1_vibration_strength_condition.getConditionName():pin1_vibration_strength.getValue(),
                                pin2_condition.getConditionName():pin2.getValue(),
                                pin2_vibration_strength_condition.getConditionName():pin2_vibration_strength.getValue(),
                                vibration_duration_condition.getConditionName():vibration_duration
                            ])

                        }
                    }
                }
            }
        }
        
        return parameters
    }
    
    static func Finish(participant_name: String, experiment_num: Int){
        /*
         * ExperimentResultArrayをJSONとしてファイルに保存
         * ファイルの書き出しはコマンドラインに直接出力する
         */
        let increase_pin_name = increase_pin_condition.getConditionName()
        let decrease_pin_name = decrease_pin_condition.getConditionName()
        let vibration_duration_name = vibration_duration_condition.getConditionName()
        let pin1_name = pin1_condition.getConditionName()
        let pin1_vibration_strength_name = pin1_vibration_strength_condition.getConditionName()
        let pin2_name = pin2_condition.getConditionName()
        let pin2_vibration_strength_name = pin2_vibration_strength_condition.getConditionName()
        let vibration_direction_name = vibration_direction_condition.getConditionName()
        var result_for_writing = ""
        result_for_writing +=
            taskNum_key + "," +
            decrease_pin_name + "," +
            increase_pin_name + "," +
            pin1_name + "," +
            pin1_vibration_strength_name + ", " +
            pin2_name + "," +
            pin2_vibration_strength_name + "," +
            vibration_duration_name + "," +
            "moving?" + "," +
            vibration_direction_name + "," +
            "correct?" + "," +
            time_key + "," +
            "\n"
         
        for result in result_experiment {
            result_for_writing += result[taskNum_key]! + ","
            if (result[increase_pin_name] != nil){
                result_for_writing +=
                    String(decrease_pin_condition.getValueToName(value: result[decrease_pin_name]!)) + "," +
                    String(increase_pin_condition.getValueToName(value: result[increase_pin_name]!)) + "," +
                    "," +
                    "," +
                    "," +
                    "," +
                    String(vibration_duration_condition.getValueToName(value: result[vibration_duration_name]!)) + "," +
                    "true" + ","
            }else{
                result_for_writing +=
                    "," +
                    "," +
                    String(pin1_condition.getValueToName(value: result[pin1_name]!)) + "," +
                    String(pin1_vibration_strength_condition.getValueToName(value: result[pin1_vibration_strength_name]!)) + "," +
                    String(pin2_condition.getValueToName(value: result[pin2_name]!)) + "," +
                    String(pin2_vibration_strength_condition.getValueToName(value: result[pin2_vibration_strength_name]!)) + "," +
                    String(vibration_duration_condition.getValueToName(value: result[vibration_duration_name]!)) + "," +
                    "false" + ","
            }
            result_for_writing += "\(result[answer_key]!),\(result[time_key]!)\n"
        }
        print(result_for_writing)
        write_to_file(file_name: make_file_name(participant_name: participant_name, experiment_num: experiment_num), write_string: result_for_writing)
    }
    
    static func OutputAll(participant_name: String){
        /*
         * ExperimentResultArrayをJSONとしてファイルに保存
         * ファイルの書き出しはコマンドラインに直接出力する
         */
        let increase_pin_name = increase_pin_condition.getConditionName()
        let decrease_pin_name = decrease_pin_condition.getConditionName()
        let vibration_duration_name = vibration_duration_condition.getConditionName()
        let pin1_name = pin1_condition.getConditionName()
        let pin1_vibration_strength_name = pin1_vibration_strength_condition.getConditionName()
        let pin2_name = pin2_condition.getConditionName()
        let pin2_vibration_strength_name = pin2_vibration_strength_condition.getConditionName()
        let vibration_direction_name = vibration_direction_condition.getConditionName()
        var result_for_writing = ""
        result_for_writing +=
            taskNum_key + "," +
            decrease_pin_name + "," +
            increase_pin_name + "," +
            pin1_name + "," +
            pin1_vibration_strength_name + ", " +
            pin2_name + "," +
            pin2_vibration_strength_name + "," +
            vibration_duration_name + "," +
            "moving?" + "," +
            vibration_direction_name + "," +
            "correct?" + "," +
            time_key + "," +
            "\n"
         
        for result in result_experiment_all {
            result_for_writing += result[taskNum_key]! + ","
            if (result[increase_pin_name] != nil){
                result_for_writing +=
                    String(decrease_pin_condition.getValueToName(value: result[decrease_pin_name]!)) + "," +
                    String(increase_pin_condition.getValueToName(value: result[increase_pin_name]!)) + "," +
                    "," +
                    "," +
                    "," +
                    "," +
                    String(vibration_duration_condition.getValueToName(value: result[vibration_duration_name]!)) + "," +
                    "true" + ","
            }else{
                result_for_writing +=
                    "," +
                    "," +
                    String(pin1_condition.getValueToName(value: result[pin1_name]!)) + "," +
                    String(pin1_vibration_strength_condition.getValueToName(value: result[pin1_vibration_strength_name]!)) + "," +
                    String(pin2_condition.getValueToName(value: result[pin2_name]!)) + "," +
                    String(pin2_vibration_strength_condition.getValueToName(value: result[pin2_vibration_strength_name]!)) + "," +
                    String(vibration_duration_condition.getValueToName(value: result[vibration_duration_name]!)) + "," +
                    "false" + ","
            }
            result_for_writing += "\(result[answer_key]!),\(result[time_key]!)\n"
        }
        print(result_for_writing)
        write_to_file(file_name: make_file_name(participant_name: participant_name, experiment_num: 0), write_string: result_for_writing)
    }
        
    static func Answer(answer: String, experimet_num: Int, trial_num: Int, time_lap_s: TimeInterval){
        /*
         * 結果をExperimentResutlArrayに連想配列として保存する。
         * 保存する値としては
         * 提示した振動時間, 提示した時間差, 提示した場所（1つ目）, 提示した場所（2つ目）, 回答した場所（1つ目）,回答した場所（2つ目）,振動の有無
         */
        var written_answer = answer
        var is_correct = false
        if(answer=="分からない" && now_parameter[0][increase_pin_condition.getConditionName()] == nil){
            is_correct = true
        }else if(answer==vibration_direction_condition.getValueToName(value: "方向1") && now_parameter[0][increase_pin_condition.getConditionName()] != nil){
            if(Int(now_parameter[0][increase_pin_condition.getConditionName()]!)! < Int(now_parameter[0][decrease_pin_condition.getConditionName()]!)! ){
                is_correct = true
            }
        }else if(answer==vibration_direction_condition.getValueToName(value: "方向2") && now_parameter[0][increase_pin_condition.getConditionName()] != nil){
            if(Int(now_parameter[0][increase_pin_condition.getConditionName()]!)! > Int(now_parameter[0][decrease_pin_condition.getConditionName()]!)! ){
                is_correct = true
            }
        }
        if(is_correct){
            written_answer += ",true"
        }else{
            written_answer += ",false"
        }
        
        now_parameter[0][answer_key] = written_answer
        now_parameter[0][taskNum_key] = "\(experimet_num), \(trial_num)"
        now_parameter[0][time_key] = "\(time_lap_s)"
        result_experiment += now_parameter
        result_experiment_all += now_parameter
    }
    
    static func hasNext()->Bool{
        return parameters.isEmpty == false
    }
    
    static func Next(){
        do {
            let encorder = JSONEncoder()
            now_parameter = [parameters.popLast()!]
            let encode_parameter = try encorder.encode(now_parameter)
            print("send : " + String(data: encode_parameter, encoding: .utf8)!)
            guard let port = port_for_send_to_Arduino else {
                print("ポート接続ができませんでした")
                return
            }
            port.send(encode_parameter)
        } catch (let e) {
            print(e)
        }
    }
    
    static func isOpen()->Bool{
        guard let port = port_for_send_to_Arduino else {
            return false
        }
        return port.isOpen()
    }
}
