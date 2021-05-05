// File:    ContentView.swift
// Project: SystemSounds
// Package: SystemSounds
// Product: SystemSounds
//
// Created by Gene De Lisa on 5/3/21
//
// Using Swift 5.0
// Running macOS 11.3
// Github: https://github.com/genedelisa/SystemSounds
// Product: https://rockhoppertech.com/
//
// Copyright © 2021 Rockhopper Technologies, Inc. All rights reserved.
//
// Licensed under the MIT License (the "License");
//
// You may not use this file except in compliance with the License.
//
// You may obtain a copy of the License at
//
// https://opensource.org/licenses/MIT
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS O//R
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



import SwiftUI

/// The SwiftUI main view.
struct ContentView: View {

    // see SystemSoundsApp
    @EnvironmentObject var audio: Audio
    // or
    // @ObservedObject var audio = Audio()
    
    @State var fullPath: Bool = false
    
    private var fcolumns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    private var columns = [
        GridItem(), GridItem()
    ]
    
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                
                ScrollView {
                    
                    LazyVGrid(
                        columns: columns,
                        alignment: .center,
                        spacing: 16
                    ) {
                        
                        Button {
                            audio.playSerena()
                        } label: {
                            Text("Custom sound")
                                .accessibility(label: Text("Play a Custom Sound"))
                                .accessibility(hint: Text("This will play a custom sound"))
                                .accessibility(identifier: "CustomSoundButton")
                        }
                        .buttonStyle(GDButtonStyle())
                        
                        Button {
                            audio.vibrate()
                        } label: {
                            Text("Vibrate")
                        }
                        .buttonStyle(GDButtonStyle())
                        
                        Button {
                            audio.annoy()
                        } label: {
                            Text("Annoy")
                        }
                        .buttonStyle(GDButtonStyle())
                        
                        Button {
                            audio.registerVibrateCompletion()
                        } label: {
                            Text("Register Vibrate completion. Call only once.")
                        }
                        .buttonStyle(GDButtonStyle())
                        
                    }
                }
                
                
                List(audio.sysSounds) { sound in
                    Button(action: {
                        audio.playSystemSound(url: sound.url)
                    }, label: {
                        if self.fullPath {
                            Text("\(sound.url.absoluteString)")
                        } else {
                            Text("\(sound.url.lastPathComponent)")
                        }
                    })
                }
                .listStyle(GroupedListStyle())
                
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Toggle(isOn: $fullPath, label: {
                                Text("Full Path")
                            })
                            
                        } label: {
                            Image(systemName: "gearshape")
                        }
                    }
                }
                
            }
            .navigationTitle("System Soundz")
        }
    }
}

/// SwiftUI preview for ContentView
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            ContentView()
                .environment(\.colorScheme, .light)
                .environment(\.locale, .init(identifier: "en"))
                .previewDevice(PreviewDevice(rawValue: "iPhone 12)"))
                .previewDisplayName("Light: iPhone 12")
            
            ContentView()
                .environment(\.colorScheme, .dark)
                .environment(\.locale, .init(identifier: "en"))
                .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
                .previewDisplayName("Dark: iPhone 12")
        }
        
    }
}

/// A Button style to keep things dry
struct GDButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        
        configuration.label
            .padding()
            .background(!configuration.isPressed ?
                            Color.blue : Color.green)
            
            .foregroundColor(!configuration.isPressed ? .white : .black)
            
            .cornerRadius(8)
            //            .clipShape(Capsule())
            .compositingGroup()
            .shadow(color: .black, radius: 3)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeOut(duration: 0.2))
    }
}
