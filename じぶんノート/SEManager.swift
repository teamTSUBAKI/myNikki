//
//  SEManager.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/01/24.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import Foundation
import AVFoundation

class SEManager:NSObject{
    
    var player:AVAudioPlayer?
    
    func sePlay(soundName:String){
        
        //サウンドファイルを読み込む
        let soundPath = (NSBundle.mainBundle().bundlePath as NSString).stringByAppendingPathComponent(soundName)
        print(soundName)
        print(soundPath)
        //読み込んだファイルにパスをつける
        let url:NSURL = NSURL.fileURLWithPath(soundPath)
        //playerによも込んだmp3ファイルへのパスを設定する
        player = try!AVAudioPlayer(contentsOfURL: url)
        //音を即時に出す
        player?.prepareToPlay()
        //音を再生
        player?.play()
        
    }
    
    
    
}
