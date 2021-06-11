//
//  AutoControlView.swift
//  Connector_iPhone_And_Arduino
//
//  Created by 日高拓真 on 2020/12/06.
//

import SwiftUI

enum Mode: String{
    case Prepare = "prepare"
    case Start = "start"
    case Running = "running"
    case Finish = "finish"
}

struct ContentView: View {
    @State var vibrationDuration: String = "0"
    @State var vibrationDirection: String = "0"
    @State var isPickersDisable: Bool = true
    @State var mode: Mode = Mode.Prepare
    @State var isNotOpen: Bool = true
    @State var isConfirm: Bool = false
    @State var isFinish: Bool = false
    @ObservedObject var textForOutput: TextForOutput = TextForOutput(first_text: "テストを始めるボタンを押して，テストを始めてください")
    @State var experiment_count: Int = 1
    @State var trial_count: Int = 1
    @State var participant_name: String = ""
    @State var experiment_button_string: String = "テストを始める"
    let vibrationDurationCondition: VibrationDuration = VibrationDuration()
    let vibrationDirectionCondition: VibrationDirection = VibrationDirection()
    @State var start_date = Date()
    @State var isAbleWatchList = false
    @State var text_AbleWatchList: String = "出力結果を見る"

    init() {
        Printer.set_text_for_output(target_text: textForOutput)
    }
    
    var body: some View {
        VStack{
            if(mode == Mode.Prepare){
                if(isAbleWatchList){
                    List(Printer.get_list_of_text(), id: \.self){
                        text in
                        if(text != "\n"){
                            Text(text)
                        }
                    }
                }
            }else if(mode == Mode.Running){
                Image("reference")
            }
            HStack{
                VStack{
                    if(mode == Mode.Prepare){
                        Text("振動を提示する時間")
                        Picker(selection: $vibrationDuration, label: Text("ラベルはlabelsHidden()によって非表示にしている")) {
                            ForEach(vibrationDurationCondition.getItemArray().map({$0.getValue()}), id: \.self){ EnumCase in
                                Text(EnumCase)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 200)
                        .labelsHidden()
                    }
                }
                VStack{
                    HStack{
                        if(mode == Mode.Prepare){
                            TextField("参加者名", text: $participant_name).textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        if(mode == Mode.Running){
                            HStack{
                                VStack{
                                    Text("振動している方向")
                                    Picker(selection: $vibrationDirection, label: Text("ラベルはlabelsHidden()によって非表示にしている"), content: {
                                        ForEach(vibrationDirectionCondition.getItemArray().map({$0.getValue()})
                                            , id: \.self){item in
                                                    Text(item)
                                                }
                                    })
                                    .pickerStyle(SegmentedPickerStyle())
                                    .frame(width: 200)
                                    .labelsHidden()
                                }
                                Button(action: {
                                    Experiment.Answer(answer: vibrationDirectionCondition.getValueToName(value: vibrationDirection), experimet_num: experiment_count, trial_num: trial_count, time_lap_s: Date().timeIntervalSince(start_date))
                                    trial_count += 1
                                    start_date = Date()
                                    if(Experiment.hasNext()){
                                        Experiment.Next()
                                    }else{
                                        isFinish = true
                                    }
                                    vibrationDirection = "0"
                                }) {
                                    Text(experiment_button_string)
                                }
                                .disabled(vibrationDirection=="0")
                                .alert(isPresented: $isFinish, content: {
                                    Alert(title: Text("実験が終了しました"), message: nil, dismissButton: .default(Text("OK"), action: {
                                        Experiment.Finish(participant_name: participant_name, experiment_num: experiment_count)
                                        experiment_count += 1
                                        trial_count = 1
                                        mode = Mode.Prepare
                                        experiment_button_string = "テストを始める"
                                        isFinish = false
                                    }))
                                })
                            }
                        }else if(mode == Mode.Start){
                            Button(action: {
                                if(Experiment.hasNext()){
                                    Experiment.Next()
                                    mode = Mode.Running
                                    start_date = Date()
                                    experiment_button_string = "回答する"
                                }
                            }) {
                                Text(experiment_button_string)
                            }
                        }else{
                            Button(action: {
                                isConfirm = true
                                Experiment.Start(vibration_duration: vibrationDuration)
                                isNotOpen = !(Experiment.isOpen())                                
                            }) {
                                Text(experiment_button_string)
                            }
                            .alert(isPresented: $isConfirm, content: {
                                Alert(title: Text("確認"), message: Text(
                                    """
以下の条件で大丈夫ですか?
参加者名:\(participant_name)
実験実施回数:\(experiment_count)
振動を提示する時間:\(vibrationDuration)
"""
                                ), primaryButton: .default(Text("OK"), action: {
                                    isConfirm = false
                                    experiment_button_string = "実験を開始する"
                                    mode = Mode.Start
                                }), secondaryButton: .default(Text("修正する"), action: {
                                    isConfirm = false
                                }))
                            })
                        }
                    }
                    if(mode == Mode.Prepare){
                        if(isAbleWatchList){
                            Button(action: {
                                Printer.reset_list_of_text()
                            }, label: {
                                Text("表示履歴を空にする")
                            })
                            Button(action: {
                                Experiment.OutputAll(participant_name: participant_name)
                            }, label: {
                                Text("全結果を出力")
                            })
                        }
                        Button(action: {
                            if(isAbleWatchList){
                                isAbleWatchList = false
                                text_AbleWatchList = "出力結果を見る"
                            }else{
                                isAbleWatchList = true
                                text_AbleWatchList = "出力結果を隠す"
                            }
                        }, label: {
                            Text(text_AbleWatchList)
                        })
                    }
                }
            }
        }
        .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealWidth: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
