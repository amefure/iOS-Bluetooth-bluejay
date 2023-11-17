//
//  ContentView.swift
//  MyBlueJay
//
//  Created by t&a on 2023/11/16.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var bluejayManager = BluejayManager.shared
    
    var body: some View {
                
        VStack {
            
            TextEditor(text: $bluejayManager.log)
                            
            Divider()
            
            Text(bluejayManager.isConnected ? "isConnected" : "No Connected")
            Text(bluejayManager.isBluetoothAvailable ? "isBluetoothAvailable" : "No BluetoothAvailable")
            
            HStack {
                Button {
                    bluejayManager.scan()
                } label: {
                    Text("Scan")
                }.padding()
                    .background(Color.cyan)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                
                Button {
                    bluejayManager.reStart()
                } label: {
                    Text("reStart")
                }.padding()
                    .background(Color.cyan)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                
                Button {
                    bluejayManager.connect()
                } label: {
                    Text("Connect")
                }.padding()
                    .background(Color.cyan)
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
            
            HStack {
                Button {
                    bluejayManager.disconnect()
                } label: {
                    Text("切断")
                }.padding()
                    .background(Color.cyan)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                
                Button {
                    bluejayManager.cancelEverything()
                } label: {
                    Text("Reset")
                }.padding()
                    .background(Color.cyan)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                
                Button {
                    bluejayManager.stopAndExtractBluetoothState()
                } label: {
                    Text("移行")
                }.padding()
                    .background(Color.cyan)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                
                Button {
                    bluejayManager.read()
                } label: {
                    Text("Read")
                }.padding()
                    .background(Color.cyan)
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
        }
    }
}

#Preview {
    ContentView()
}
