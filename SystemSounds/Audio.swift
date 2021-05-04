// File:    Audio.swift
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



import AVFoundation
import os.log

/// A wrapper to be used in SwiftUI Lists
struct SysSound: Identifiable {
    var id = UUID()
    var url: URL
}

/// An observable class that publishes standard system sounds.
/// It also provides audio functions that the client can call.
class Audio: ObservableObject {
    
    /// an os logger with the Audio category
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Audio")
    
    /// The items used in the SwiftUI List
    @Published var sysSounds = [SysSound]()

    /// a local handle
    var serena: SystemSoundID = .zero
    
    init() {
        self.logger.trace("\(#function)")
        
        if let surls = findSystemSounds() {
            sysSounds = surls.map() { SysSound(url: $0) }
                .sorted(by: { a, b in
                    return a.url.absoluteString < b.url.absoluteString
                })

            for url in surls {
                logger.debug("\(url.absoluteString)")
            }
        } else {
            logger.error("Could not retrieve system sounds")
        }

        // playSerena() will do this on demand
        serena = createSysSound(fileName: "serena", fileExt: "m4a")
    }
    
    /// A client side callable function. Hides the details.
    /// This will create a system sound for a custom sound file and play it.
    func playSerena() {
        if serena == .zero {
            serena = createSysSound(fileName: "serena", fileExt: "m4a")
        }
        AudioServicesPlaySystemSound(serena)
    }
    
    
    /// Find all of the standard system sounds.
    /// - Returns: An array of the file urls to the system sounds.
    func findSystemSounds() -> [URL]? {
        self.logger.trace("\(#function)")
        
        #if targetEnvironment(simulator)
        self.logger.debug("Sounds not available on the simulator")
        return nil

        #else
        
        var fileURLs = [URL]()
        let soundDir = "/System/Library/Audio/UISounds"
        let soundDirURL = URL(fileURLWithPath: soundDir)
        // also reads subdirs
        // /System/Library/Audio/UISounds/Modern
        // /System/Library/Audio/UISounds/New and nono
        
        let fileManager = FileManager.default
        
        if let enumerator = fileManager.enumerator(atPath: soundDirURL.path) {
            for case let name as String in enumerator {
                if name.hasSuffix(".caf") {
                    let fu = soundDirURL.appendingPathComponent(name)
                    fileURLs.append(fu)
                }
            }
        } else {
            print("can not enumerate \(soundDirURL.absoluteString)")
        }
        return fileURLs

        #endif
    }
    

    /// Find the standard system sounds, skipping the subdirectories.
    /// - Returns: An array of the file urls to the system sounds.
    func findSystemSoundsNonRecursive() -> [URL]? {
        self.logger.trace("\(#function)")

        #if targetEnvironment(simulator)
        self.logger.debug("Sounds not available on the simulator")
        return nil
        #else
        
        var fileURLs = [URL]()
        let soundDir = "/System/Library/Audio/UISounds"
        let soundDirURL = URL(fileURLWithPath: soundDir)
        let urls: [URL]
        do {
            let fileManager = FileManager.default
            try urls = fileManager.contentsOfDirectory(at: soundDirURL,
                                                       includingPropertiesForKeys: [URLResourceKey.isReadableKey],
                                                       options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)

            // if you're paranoid
            fileURLs = urls.filter{ $0.pathExtension == "caf" }
            
        } catch {
            return nil
        }
        return fileURLs
        #endif
    }
    
    
    /// Plays a system sound.
    /// - Parameter url: The file URL to the sound file
    func playSystemSound(url: URL) {
        self.logger.trace("\(#function)")
        
        var soundID: SystemSoundID = .zero
        let osstatus = AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
        if osstatus != noErr {
            print("could not get system sound at url: \(url.absoluteString)")
            print("osstatus: \(osstatus)")
            return
        }
        AudioServicesPlaySystemSound(soundID)
    }
    
    /// Create a System sound from a custom sound file.
    /// - Parameters:
    ///   - fileName: The base name of the sound file.
    ///   - fileExt: The file extension.
    /// - Returns: a SystemSoundID that can be played
    func createSysSound(fileName: String, fileExt: String) -> SystemSoundID {
        var mySysSound: SystemSoundID = .zero
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExt) else {
            return .zero
        }
        let osstatus = AudioServicesCreateSystemSoundID(url as CFURL, &mySysSound)
        if osstatus != noErr {
            print("could not create system sound")
            print("osstatus: \(osstatus)")
        }
        return mySysSound
    }
    
    /*
     on my iPad 2021
     file:///System/Library/Audio/UISounds/SIMToolkitNegativeACK.caf
     file:///System/Library/Audio/UISounds/key_press_delete.caf
     file:///System/Library/Audio/UISounds/acknowledgment_received.caf
     file:///System/Library/Audio/UISounds/SIMToolkitPositiveACK.caf
     file:///System/Library/Audio/UISounds/short_double_high.caf
     file:///System/Library/Audio/UISounds/acknowledgment_sent.caf
     file:///System/Library/Audio/UISounds/tweet_sent.caf
     file:///System/Library/Audio/UISounds/end_record.caf
     file:///System/Library/Audio/UISounds/begin_record.caf
     file:///System/Library/Audio/UISounds/Modern/
     file:///System/Library/Audio/UISounds/SIMToolkitCallDropped.caf
     file:///System/Library/Audio/UISounds/Tink.caf
     file:///System/Library/Audio/UISounds/short_double_low.caf
     file:///System/Library/Audio/UISounds/Tock.caf
     file:///System/Library/Audio/UISounds/sms-received2.caf
     file:///System/Library/Audio/UISounds/focus_change_small.caf
     file:///System/Library/Audio/UISounds/access_scan_complete.caf
     file:///System/Library/Audio/UISounds/nano/
     file:///System/Library/Audio/UISounds/lock.caf
     file:///System/Library/Audio/UISounds/sms-received3.caf
     file:///System/Library/Audio/UISounds/sms-received1.caf
     file:///System/Library/Audio/UISounds/ct-path-ack.caf
     file:///System/Library/Audio/UISounds/keyboard_press_clear.caf
     file:///System/Library/Audio/UISounds/3rd_party_critical.caf
     file:///System/Library/Audio/UISounds/sms-received4.caf
     file:///System/Library/Audio/UISounds/SIMToolkitSMS.caf
     file:///System/Library/Audio/UISounds/photoShutter.caf
     file:///System/Library/Audio/UISounds/camera_timer_countdown.caf
     file:///System/Library/Audio/UISounds/sms-received5.caf
     file:///System/Library/Audio/UISounds/SIMToolkitGeneralBeep.caf
     file:///System/Library/Audio/UISounds/middle_9_short_double_low.caf
     file:///System/Library/Audio/UISounds/focus_change_large.caf
     file:///System/Library/Audio/UISounds/SentMessage.caf
     file:///System/Library/Audio/UISounds/sms-received6.caf
     file:///System/Library/Audio/UISounds/RingerChanged.caf
     file:///System/Library/Audio/UISounds/navigation_push.caf
     file:///System/Library/Audio/UISounds/jbl_no_match.caf
     file:///System/Library/Audio/UISounds/payment_failure.caf
     file:///System/Library/Audio/UISounds/warsaw.caf
     file:///System/Library/Audio/UISounds/navigation_pop.caf
     file:///System/Library/Audio/UISounds/health_notification.caf
     file:///System/Library/Audio/UISounds/key_press_modifier.caf
     file:///System/Library/Audio/UISounds/nfc_scan_failure.caf
     file:///System/Library/Audio/UISounds/ct-busy.caf
     file:///System/Library/Audio/UISounds/camera_timer_final_second.caf
     file:///System/Library/Audio/UISounds/wheels_of_time.caf
     file:///System/Library/Audio/UISounds/low_power.caf
     file:///System/Library/Audio/UISounds/long_low_short_high.caf
     file:///System/Library/Audio/UISounds/mail-sent.caf
     file:///System/Library/Audio/UISounds/jbl_begin.caf
     file:///System/Library/Audio/UISounds/short_low_high.caf
     file:///System/Library/Audio/UISounds/focus_change_keyboard.caf
     file:///System/Library/Audio/UISounds/jbl_confirm.caf
     file:///System/Library/Audio/UISounds/keyboard_press_delete.caf
     file:///System/Library/Audio/UISounds/connect_power.caf
     file:///System/Library/Audio/UISounds/focus_change_app_icon.caf
     file:///System/Library/Audio/UISounds/keyboard_press_normal.caf
     file:///System/Library/Audio/UISounds/go_to_sleep_alert.caf
     file:///System/Library/Audio/UISounds/ReceivedMessage.caf
     file:///System/Library/Audio/UISounds/ct-congestion.caf
     file:///System/Library/Audio/UISounds/key_press_click.caf
     file:///System/Library/Audio/UISounds/ct-keytone2.caf
     file:///System/Library/Audio/UISounds/jbl_cancel.caf
     file:///System/Library/Audio/UISounds/new-mail.caf
     file:///System/Library/Audio/UISounds/shake.caf
     file:///System/Library/Audio/UISounds/New/
     file:///System/Library/Audio/UISounds/multiway_invitation.caf
     file:///System/Library/Audio/UISounds/ct-error.caf
     file:///System/Library/Audio/UISounds/ussd.caf
     file:///System/Library/Audio/UISounds/jbl_ambiguous.caf
     file:///System/Library/Audio/UISounds/nfc_scan_complete.caf
     file:///System/Library/Audio/UISounds/Swish.caf
     file:///System/Library/Audio/UISounds/payment_success.caf
     file:///System/Library/Audio/UISounds/alarm.caf
     
     */
    
    
    
    func foo(directoryURL: URL) {
        
        //        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //        guard let directoryURL = URL(string: paths.path) else {return}
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: directoryURL,
                                                                       includingPropertiesForKeys:[.contentModificationDateKey],
                                                                       options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
                .filter { $0.lastPathComponent.hasSuffix(".caf") }
                .sorted(by: {
                    let date0 = try $0.promisedItemResourceValues(forKeys:[.contentModificationDateKey]).contentModificationDate!
                    let date1 = try $1.promisedItemResourceValues(forKeys:[.contentModificationDateKey]).contentModificationDate!
                    return date0.compare(date1) == .orderedDescending
                })
            
            for item in contents {
                guard let t = try? item.promisedItemResourceValues(forKeys:[.contentModificationDateKey]).contentModificationDate
                else {
                    return
                }
                print ("\(t)   \(item.lastPathComponent)")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

/*
 let fileManager = FileManager.default
 
 // with error handler and properties
 //        let eh: (URL, Error) -> Bool = {
 //            (url, error) -> Bool in
 //            return true
 //        }
 //        if let enumerator = fileManager.enumerator(at: soundDirURL,
 //                                                   includingPropertiesForKeys: [.contentTypeKey],
 //                                                   options: [.skipsHiddenFiles],
 //                                                   errorHandler: eh) {
 //        }

 */
