//
//  SerialDelegate.swift
//  iPhone2Arduino
//
//  Created by 日高拓真 on 2020/07/28.
//  Copyright © 2020 日高拓真. All rights reserved.
//

import Foundation
import ORSSerial

class SerialController: NSObject, ORSSerialPortDelegate, ObservableObject {
    /// 改行が入力されるまでの文字列を格納するテキストバッファ
    private var textBuffer = ""
    private static var Port: ORSSerialPort?
    private static var singleton: SerialController = SerialController()
    static public func get_Port() -> SerialController{
        return SerialController.singleton
    }
    
    private let portName: String = "自身の環境のものを入れる"
    private let baudRate: NSNumber = 9600
    
    private override init() {
        super.init()
        
        SerialController.Port = ORSSerialPort(path: portName)
        SerialController.Port?.delegate = self
        SerialController.Port?.baudRate = baudRate
        SerialController.Port?.open()
    }
    
    public func isOpen() -> Bool {
        guard let port = SerialController.Port else {
            return false
        }
        return port.isOpen
    }
    
    public func send(_ data: Data){
        guard let port = SerialController.Port else {
            print("ポートが発見できませんでした")
            Printer.print_to_List(print_string: "ポートが発見できませんでした")
            return
        }
        print(String(data: data, encoding: .utf8)!)
        port.send(data)
    }
    
    public func close(){
        guard let port = SerialController.Port else {
            Printer.print_to_List(print_string: "ポートが発見できませんでした")
            return
        }
        port.close()
    }
    
    /// ポートからの入力を検知した際に呼ばれる
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        guard let receive_text: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? else { return }
        /// 改行がある時、textBufferに追加して、表示する
        /// 改行がない時、textBufferに追加する
        guard receive_text.contains("\r") || receive_text.contains("\n") else {
            textBuffer +=
                receive_text
                .replacingOccurrences(of: "\r", with: "")
                .replacingOccurrences(of: "\n", with: "")
            return
        }

        textBuffer += receive_text
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: "\n", with: "")

        Printer.print_to_List(print_string: "From Arduino: " + textBuffer)
        print(textBuffer)
        textBuffer = ""
    }

    /// ポート接続がシステムから開放された際に呼ばれる
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        print("シリアルポート（ポート番号：\(serialPort)）をシステムから開放しました")
    }

    /// ポート接続にエラーが生じた際に呼ばれる
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        print("シリアルポート (ポート番号：\(serialPort)) でエラーが発生しました: \(error)")
    }

    /// ポート接続が完了した際に呼ばれる
    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        print("シリアルポート（ポート番号：\(serialPort)）に接続されました")
        Printer.print_to_List(print_string: "シリアルポート（ポート番号：\(serialPort)）に接続されました")
    }
}
