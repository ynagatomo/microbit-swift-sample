//
//  ContentView.swift
//  microbit-swift-controller-sample-app
//
//  Created by Yasuhito Nagatomo on 2023/05/06.
//

import SwiftUI
import MicrobitSwiftController

struct ContentView: View {
    @StateObject var microbit = MicrobitSwiftController()
    @State var textOnLed = ""
    @State var analogOutValue = 0.0

    var body: some View {
        VStack {
            Text("Micro:bit Swift Package Sample App")
                .font(.title2)
                .padding(8)

            HStack(alignment: .bottom) {
                VStack {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.title)
                    Text("Bluetooth: \(microbit.bluetoothEnabled ? "Enable" : "Disable")")
                        .padding(8)
                }
                .foregroundColor(microbit.bluetoothEnabled ? .blue : .gray)

                VStack {
                    Image(systemName: "rectangle.connected.to.line.below")
                        .font(.title)
                    Text("\(microbit.connected ? "Connected" : "Not connected")")
                        .padding(8)
                }
                .foregroundColor(microbit.connected ? .green : .gray)
            }
            .font(.title3)
            .padding(8)

            HStack(alignment: .bottom) {
                VStack {
                    Circle()
                        .fill(.gray)
                        .frame(width: 160, height: 160)
                        .overlay {
                            Circle()
                                .fill(.orange)
                                .frame(width: 20, height: 20)
                                .offset(x: CGFloat(microbit.accelerometer.x) * 50,
                                        y: CGFloat(microbit.accelerometer.y) * 50)
                        }
                    Text("Accelerometer")
                }

                VStack {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 160))
                        .foregroundColor(.indigo)
                        .rotationEffect(Angle(degrees: Double(microbit.magnetometer.z) / 40 * 180))
                    Text("\(microbit.magnetometer.z, specifier: "%2.1f") [uT]")
                }
            }

            VStack {
                Text("Display Text on LED")
                TextField("Text on LED", text: $textOnLed)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        microbit.display(text: textOnLed)
                    }

                VStack {
                    Text("LED Matrix")
                    HStack {
                        Image(systemName: "squareshape.dotted.split.2x2")
                            .font(.system(size: 64))
                            .foregroundColor(.red)
                        Text("Push Button B on Micro:bit")
                    }
                }
                .padding()

            }
            .padding()

            VStack {
                Text("P1 Analog Output")
                Slider(value: $analogOutValue, in: 0.0...1.0, step: 0.1)
                    .onChange(of: analogOutValue) { value in
                        microbit.output(analogPins: [MicrobitSwiftController.PWMData(pin: 1,
                                                                                     value: UInt16(1024 * analogOutValue),
                                                                                     period: 1_00_000)]) // usec
                    }
            }
            .padding()

            Spacer()

            HStack {
                Button(action: {
                    microbit.connect()
                }, label: {
                    Text("Connect")
                        .font(.title2)
                })
                .buttonStyle(.borderedProminent)
                .disabled(microbit.connected)
                .padding()

                Button(action: {
                    microbit.disconnect()
                }, label: {
                    Text("Disconnect")
                        .font(.title2)
                })
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .disabled(!microbit.connected)
                .padding()
            }
        }
        .padding()
        .onChange(of: microbit.buttonB) { value in
            displayDots(value)
        }
        .onChange(of: microbit.connected) { value in
            if microbit.connected {
                microbit.configure(inputPins: [])
                microbit.configure(analogPins: [1])
                microbit.setMagnetometer(period: .eighty)
                microbit.setAccelerometer(period: .eighty)
            }
        }
        .onAppear {
            microbit.start()
        }
    }

    func displayDots(_ state: MicrobitSwiftController.ButtonState) {
        if state == .on {
            microbit.display(matrix: [UInt8(0x00),
                                      UInt8(0x00),
                                      UInt8(0x04),
                                      UInt8(0x00),
                                      UInt8(0x00)])
            microbit.wait(milliseconds: 200)
            microbit.display(matrix: [UInt8(0x00),
                                      UInt8(0x0e),
                                      UInt8(0x0a),
                                      UInt8(0x0e),
                                      UInt8(0x00)])
            microbit.wait(milliseconds: 200)
            microbit.display(matrix: [UInt8(0x1f),
                                      UInt8(0x11),
                                      UInt8(0x11),
                                      UInt8(0x11),
                                      UInt8(0x1f)])
            microbit.wait(milliseconds: 200)
            microbit.display(matrix: [UInt8(0x0),
                                      UInt8(0x0),
                                      UInt8(0x0),
                                      UInt8(0x0),
                                      UInt8(0x0)])
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
