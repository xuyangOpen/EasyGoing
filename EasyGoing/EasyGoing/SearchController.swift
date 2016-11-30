//
//  SearchController.swift
//  EasyGoing
//
//  Created by King on 16/11/23.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

protocol SearchControllerDelegate:NSCoding {
    //滚动tableview时，调用代理方法，收起键盘
    func cancelEditing() -> Void
    //点击选中的cell，选择搜索地区
    func choosePlaceByCoordinate(point: CGPoint, placeName: String) -> Void
}

class SearchController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    let searchTableView = UITableView()
    
    var dataSource = [SearchModel]()
    
    weak var delegate:SearchControllerDelegate?
    //显示的内容是历史记录，还是搜索结果，默认是历史记录
    let historyFilePath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0].stringByAppendingString("/searchHistory.plist")
    var showModel = ""{
        didSet{
            if showModel == "history" {
                //解档
                var tempDataSource = [SearchModel]()
                let object = NSKeyedUnarchiver.unarchiveObjectWithFile(self.historyFilePath)
                if object != nil {
                    tempDataSource = object as! [SearchModel]
                    self.dataSource = tempDataSource
                    self.searchTableView.reloadData()
                }
            }
        }
    }
    
    //清除历史记录的按钮
    let clearButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        //设置UITableview
        self.configTableView()
    }
    
    //MARK:设置UITableview
    func configTableView(){
        self.searchTableView.frame = CGRectMake(0, 64, Utils.screenWidth, Utils.screenHeight - 64)
        self.searchTableView.backgroundColor = UIColor.whiteColor()
        self.searchTableView.delegate = self
        self.searchTableView.dataSource = self
        self.searchTableView.separatorStyle = .None
        self.view.addSubview(self.searchTableView)
        
        //注册cell
        self.searchTableView.registerClass(SearchViewCell.self, forCellReuseIdentifier: "destinationSearchCell")
    }
    
    //MARK:UITableView代理方法
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.showModel == "history" {
            if self.dataSource.count == 0 {
                return 0
            }
            return self.dataSource.count + 1
        }else{
            return self.dataSource.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.showModel == "history" && indexPath.row == self.dataSource.count {
            //如果是历史记录最后一条，则显示清除历史记录
            let cell = UITableViewCell.init(style: .Default, reuseIdentifier: "historyCell")
            self.clearButton.setTitle("清除历史记录", forState: .Normal)
            self.clearButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
            self.clearButton.titleLabel?.font = UIFont.systemFontOfSize(14)
//            self.clearButton.layer.borderColor = UIColor.grayColor().CGColor
//            self.clearButton.layer.borderWidth = 0.5
            self.clearButton.addTarget(self, action: #selector(clearHistory), forControlEvents: .TouchUpInside)
            cell.contentView.addSubview(self.clearButton)
    
            self.clearButton.snp_makeConstraints(closure: { (make) in
                make.center.equalToSuperview()
                make.size.equalTo(CGSizeMake(Utils.scaleFloat(120), 25))
            })
            
            cell.selectionStyle = .None
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("destinationSearchCell") as! SearchViewCell
            
            cell.setModel(self.dataSource[indexPath.row])
            cell.selectionStyle = .None
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < self.dataSource.count {
            //点击cell时，调用代理方法，返回经纬度
            if indexPath.row < self.dataSource.count && self.delegate != nil {
                let model = self.dataSource[indexPath.row]
                
                self.delegate?.choosePlaceByCoordinate(self.dataSource[indexPath.row].ptInfo.CGPointValue(), placeName: model.placeKey)
                //保存历史记录
                self.saveHistory(model)
            }else{
                Utils.showMessageOnView(self.view, message: "当前位置不可用", time: 1.5, block: nil)
            }
        }
    }
    
    //MARK:刷新UITableView
    func refreshTableView(){
        var height = 60 * CGFloat(self.dataSource.count)
        if height > (Utils.screenHeight-44) {
            height = Utils.screenHeight-44
        }
        self.searchTableView.frame = CGRectMake(0, 44, Utils.screenWidth, height)
        self.searchTableView.reloadData()
    }
    
    //MARK:滚动tableview时
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.delegate != nil {
            self.delegate?.cancelEditing()
        }
    }
    
    //MARK:历史记录存档
    func saveHistory(model: SearchModel){
        //解档
        var tempDataSource = [SearchModel]()
        let object = NSKeyedUnarchiver.unarchiveObjectWithFile(self.historyFilePath)
        if object != nil {
            tempDataSource = object as! [SearchModel]
        }
        
        var isExist = false
        for item in tempDataSource {
            if item.placeKey == model.placeKey {
                isExist = true
                break
            }
        }
        //存档
        if !isExist{//如果当前搜索地址不在历史记录中，才保存
            tempDataSource.append(model)
            //判断路径是否存在，如果不存在，则创建
            if !NSFileManager.defaultManager().fileExistsAtPath(self.historyFilePath) {
                let flag = NSFileManager.defaultManager().createFileAtPath(self.historyFilePath, contents: nil, attributes: nil)
                if flag {
                    print("文件创建成功")
                }else{
                    print("文件创建失败")
                }
            }
            NSKeyedArchiver.archiveRootObject(tempDataSource, toFile: self.historyFilePath)
        }
    }
    
    //MARK:清除历史记录
    func clearHistory(){
        NSKeyedArchiver.archiveRootObject([SearchModel](), toFile: self.historyFilePath)
        self.dataSource.removeAll()
        self.searchTableView.reloadData()
    }
    
}

