//
//  SelectPromptMusicViewController.swift
//  EasyGoing
//
//  Created by King on 16/11/29.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit
import AVOSCloud

class SelectPromptMusicViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    let musicTableView = UITableView()
    let identifier = "musicCell"
    var defaultMusic = ""
    var defaultIndex = -1
    //顶峰、灯塔、新闻快讯、海边、钟声、往复、星座、宇宙、水晶、山涧
    //照明、猫头鹰、开场、欢乐时光、急板、雷达、辐射、流水、煎茶 、信号
    //丝绸、缓慢上升、悉心期盼 、山顶、闪烁、举起、波浪
    let musicDataSource =
        ["顶峰","灯塔","新闻快讯","海边","钟声","往复","星座","宇宙","水晶","山涧",
        "照明","猫头鹰","开场","欢乐时光","急板","雷达","辐射","流水","煎茶","信号",
        "丝绸","缓慢上升","悉心期盼","山顶","闪烁","举起","波浪"]
    let musicResources =
        ["Apex","Beacon","Bulletin","By The Seaside","Chimes",
        "Circuit","Constellation","Cosmic","Crystals","Hillside",
        "Illuminate","Night Owl","Opening","Playtime","Presto",
        "Radar","Radiate","Ripples","Sencha","Signal",
        "Silk","Slow Rise","Stargaze","Summit","Twinkle",
        "Uplift","Waves"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.title = "提示音"
        //设置默认音乐
        if AVUser.currentUser()?.objectForKey("destinationPromptMusic") != nil{
            self.defaultMusic = AVUser.currentUser()?.objectForKey("destinationPromptMusic") as! String
        }else{
            self.defaultMusic = "By The Seaside"
        }
        
        self.configMusicTableView()
    }
    
    //MARK:设置UITableview
    func configMusicTableView(){
        self.musicTableView.delegate = self
        self.musicTableView.dataSource = self
        self.musicTableView.backgroundColor = UIColor.whiteColor()
        self.musicTableView.frame = self.view.frame
        self.view.addSubview(self.musicTableView)
        
        self.musicTableView.registerClass(PromptDistanceCell.self, forCellReuseIdentifier: identifier)
    }
    
    //MARK:UITableView的代理方法
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.musicDataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! PromptDistanceCell
        if self.musicResources[indexPath.row] == self.defaultMusic || self.defaultIndex == indexPath.row{
            self.defaultIndex = indexPath.row
            cell.setData(self.musicDataSource[indexPath.row], isChoose: true)
        }else{
            cell.setData(self.musicDataSource[indexPath.row], isChoose: false)
        }
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.defaultIndex >= 0 {//将之前选中的cell复原
            //如果cell在可视范围内
            if tableView.cellForRowAtIndexPath(NSIndexPath.init(forRow: self.defaultIndex, inSection: 0)) != nil {
                let cell = tableView.cellForRowAtIndexPath(NSIndexPath.init(forRow: self.defaultIndex, inSection: 0)) as! PromptDistanceCell
                cell.setData(self.musicDataSource[self.defaultIndex], isChoose: false)
            }
        }
        //将当前cell选中
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! PromptDistanceCell
        cell.setData(self.musicDataSource[indexPath.row], isChoose: true)
        self.defaultIndex = indexPath.row
        self.defaultMusic = self.musicResources[indexPath.row]
        
        //选中时，播放音乐
        SystemMusic.shareInstance.playMusic(self.defaultMusic, times: 0)
        
        //当前选中音乐保存
        AVUser.currentUser()?.setObject(self.defaultMusic, forKey: "destinationPromptMusic")
        AVUser.currentUser()?.saveInBackground()
    }
    
    
    deinit{
        SystemMusic.shareInstance.stopMusic()
        print("选择提示音乐界面释放")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
