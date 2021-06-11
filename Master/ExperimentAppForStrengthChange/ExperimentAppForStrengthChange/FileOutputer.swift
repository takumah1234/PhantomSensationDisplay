//
//  FileOutputer.swift
//  ExperimentAppForStrengthChange
//
//  Created by 日高拓真 on 2021/01/11.
//
// フォルダの保存先Path: /Users/hidakatakuma/Library/Containers/com.takuma.ExperimentAppForStrengthChange/Data/Documents

import Foundation

func write_to_file(file_name: String, write_string: String){
    let dir = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    ).first!
    let fileUrl = dir.appendingPathComponent(file_name)

    FileManager.default.createFile(atPath: fileUrl.path, contents: write_string.data(using: .utf8), attributes: nil)
    print("Write File URL: \(fileUrl)")
}

func make_file_name(participant_name: String, experiment_num: Int) -> String {
    return participant_name + "-" + String(experiment_num) + "-" + get_today_and_now_time() + ".csv"
}

func get_today_and_now_time() -> String{
    let now = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ja_JP")
    dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
    return dateFormatter.string(from: now) // 2018-10-28-18-17-38
}
