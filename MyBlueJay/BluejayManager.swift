//
//  BluejayManager.swift
//  MyBlueJay
//
//  Created by t&a on 2023/11/17.
//

import UIKit
import Bluejay
import CoreBluetooth

let service = ServiceIdentifier(uuid: "00000000-0000-1111-1111-111111111111")
let readCharacteristic = CharacteristicIdentifier(uuid: "00000000-1111-1111-1111-111111111111", service: service)
let writeCharacteristicUUID = CharacteristicIdentifier(uuid: "00000000-2222-1111-1111-111111111111", service: service)


class BluejayManager: ObservableObject {
    
    /// シングルトン
    static var shared = BluejayManager()

    /// ログ出力用
    @Published var log = ""
    
    /// bluejayインスタンス
    public var bluejay = Bluejay()
    
    /// スキャン時に発見したペリフェラル一覧
    private var discoveries: [ScanDiscovery] = []
    
    /// 接続中
    public var isConnected: Bool {
        bluejay.isConnected
    }
    
    /// BLE有効/無効
    public var isBluetoothAvailable: Bool {
        bluejay.isBluetoothAvailable
    }
    
    init() {
        config()
    }

    /// 初期設定
    private func config() {
        self.bluejay.register(logObserver: self)
        bluejay.registerDisconnectHandler(handler: self)
        bluejay.register(connectionObserver: self)
        bluejay.register(serviceObserver: self)
        self.bluejay.start()
    }
    
    /// スキャン
    public func scan() {
        log.append("スキャン開始\n")
        bluejay.scan(
            serviceIdentifiers: [service],
            discovery: { [weak self] (discovery, discoveries) -> ScanAction in
                guard let weakSelf = self else {
                    return .stop
                }

                weakSelf.log.append("発見: \(discoveries.count)個\n")
                weakSelf.discoveries = discoveries

                return .continue
            },
            stopped: { (discoveries, error) in
                if let error = error {
                    self.log.append("スキャン停止エラー: \(error.localizedDescription)\n")
                }
                else {
                    self.log.append("スキャン停止\n")
                }
        })
    }
    
    /// コネクト
    public func connect() {
        log.append("コネクト\n")
        guard let peripheral = discoveries.first else {
            log.append("サービスなし\n")
            return
        }
        bluejay.connect(peripheral.peripheralIdentifier, timeout: .seconds(15)) { result in
            switch result {
            case .success:
                self.log.append("コネクト成功: \(peripheral.peripheralIdentifier)\n")
            case .failure(let error):
                self.log.append("コネクト失敗エラー: \(error.localizedDescription)\n")
            }
        }
    }
    
    /// 切断
    public func disconnect() {
        if bluejay.isConnected {
            log.append("切断\n")
            /// 切断(キューの終了を待って)
            bluejay.disconnect()
            /// 即時切断(キューの終了を待たずに)
            // bluejay.disconnect(immediate: true)
        }
    }
    
    /// リセット
    public func cancelEverything() {
        log.append("リセット\n")
        /// キューをリセット
        bluejay.cancelEverything()
    }
    
    private var cbPeripheral: CBPeripheral?
    private var cbCentralManager: CBCentralManager!
    
    /// CoreBluetoothへの移行
    public func stopAndExtractBluetoothState() {
        log.append("移行\n")
        let status = bluejay.stopAndExtractBluetoothState()
        cbCentralManager = status.manager
        if let peripheral = status.peripheral {
            cbPeripheral = peripheral
        }
    }
    
    /// 移行後に再スタート
    public func reStart() {
        guard let cbPeripheral = self.cbPeripheral else {
            return
        }
        log.append("再スタート\n")
        bluejay.start(mode: .use(manager: cbCentralManager, peripheral: cbPeripheral))
    }
    
    
    /// Read処理
    public func read() {
        bluejay.read(from: readCharacteristic) { [weak self] (result: ReadResult<UInt8>) in
            guard let weakSelf = self else {
                 return
            }
            switch result {
            case .success(let location):
                weakSelf.log.append("Read成功: \(location)\n")
            case .failure(let error):
                weakSelf.log.append("Read失敗: \(error.localizedDescription)\n")
            }
        }
    }
}

extension BluejayManager: LogObserver, ConnectionObserver, ServiceObserver, DisconnectHandler {
    
    func didDisconnect(from peripheral: PeripheralIdentifier, with error: Error?, willReconnect autoReconnect: Bool) -> AutoReconnectMode {
        AutoReconnectMode.noChange
    }
    
    func didModifyServices(from peripheral: PeripheralIdentifier, invalidatedServices: [ServiceIdentifier]) { }
    
    func bluetoothAvailable(_ available: Bool) { }
    
    func connected(to peripheral: PeripheralIdentifier) { }

    func disconnected(from peripheral: PeripheralIdentifier) { }
    
    func debug(_ text: String) { }
}

