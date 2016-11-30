//
//  SystemMusic.swift
//  EasyGoing
//
//  Created by King on 16/11/28.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit
import AVFoundation

class SystemMusic: NSObject {

    static let shareInstance = SystemMusic()
    private override init() {}
 
    var musicPlayer:AVAudioPlayer?
    
    func playMusic(musicName: String,times: Int){
        //将前一次的播放停止并释放
        self.stopMusic()
        let musicURL = NSURL.init(fileURLWithPath: NSBundle.mainBundle().pathForResource(musicName, ofType: "m4r")!)
        musicPlayer = try?AVAudioPlayer.init(contentsOfURL: musicURL)
        
        let audioSession = AVAudioSession.sharedInstance()
        let error = try?audioSession.setCategory(AVAudioSessionCategoryPlayback) ?? nil
        print("error = \(error)")
        
        //播放times + 1次  小于0表示循环播放
        musicPlayer?.numberOfLoops = times
        if musicPlayer!.prepareToPlay(){
            musicPlayer!.play()
        }
    }
    
    func stopMusic(){
        if musicPlayer != nil {
            musicPlayer?.stop()
            musicPlayer = nil
        }
    }
    
    /*
     AVAudioSessionCategoryAmbient
     这个类别不会停止其他应用的声音,相反,它允许你的音频播放于其他应用的声音之 上,比如 iPod。你的应用的主 UI 线程会工作正常。调用 AVAPlayer 的 prepareToPlay 和 play 方法都将返回 YES。
     
     AVAudioSessionCategorySoloAmbient
     这个非常像 AVAudioSessionCategoryAmbient 类别,除了会停止其他程序的音频回放,比如 iPod 程序。当设备被设置为静音模式,你的音频回放将会停止。
     
     AVAudioSessionCategoryRecord
     这会停止其他应用的声音(比如 iPod)并让你的应用也不能初始化音频回放(比如 AVAudioPlayer)。在这种模式下,你只能进行录音。使用这个类别,调用 AVAudioPlayer 的 prepareToPlay 会返回 YES,但是调用 play 方法将返回 NO。主 UI 界面会照常工作。这时, 即使你的设备屏幕被用户锁定了,应用的录音仍会继续。
     
     AVAudioSessionCategoryPlayback
     这个类别会禁止其他应用的音频回放(比如 iPod 应用的音频回放)。你可以使用 AVAudioPlayer 的 prepareToPlay 和 play 方法,在你的应用中播放声音。主 UI 界面会照常工作。这时,即使屏幕被锁定或者设备为静音模式,音频回放都会继续。
     
     AVAudioSessionCategoryPlayAndRecord
     这个类别允许你的应用中同时进行声音的播放和录制。当你的声音录制或播放开始后, 其他应用的声音播放将会停止。主 UI 界面会照常工作。这时,即使屏幕被锁定或者设备为 静音模式,音频回放和录制都会继续。
     
     AVAudioSessionCategoryAudioProcessing
     这个类别用于应用中进行音频处理的情形,而不是音频回放或录制。设置了这种模式, 你在应用中就不能播放和录制任何声音。调用 AVAPlayer 的 prepareToPlay 和 play 方法都将 返回 NO。其他应用的音频回放,比如 iPod,也会在此模式下停止。
     */
}
