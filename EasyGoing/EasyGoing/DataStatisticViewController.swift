//
//  DataStatisticViewController.swift
//  EasyGoing
//
//  Created by King on 16/10/9.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

//MARK:数据统计控制器视图
class DataStatisticViewController: UIViewController {

    //分段控制器
    let segmentView = UISegmentedControl.init(items: ["消费项目","年统计"])
    //滑动视图
    let containerView = UIScrollView()
    //饼视图
    let pieViewChartController = PieViewController()
    
    //数据源
    var dataSource = [TimeLineRecord]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.setTitleView()
        
        //网络加载数据
        Utils.sharedInstance.showLoadingView("数据加载中")
        self.getNetData()
    }

    //MARK:设置标题视图
    func setTitleView(){
        self.segmentView.selectedSegmentIndex = 0
        self.navigationItem.titleView = self.segmentView
    }
    
    //MARK:请求网络数据
    func getNetData(){
        //查询数据
        let query = AVQuery.init(className: "TimeLineRecord")
        //级联查询子目录
        query.includeKey("eventObject")
        //二级级联查询，查询子目录的父目录
        query.includeKey("eventObject.parentId")
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            Utils.sharedInstance.hud.hideAnimated(true)
            if error == nil{
                self.dataSource.removeAll()
                if objects.count > 0{
                    for obj in objects{
                        self.dataSource.append(TimeLineRecord.initRecordWithAVObject(obj as! AVObject))//添加数据
                    }
                    //配置视图
                    self.configMainView()
                }else{
                    Utils.showHUDWithMessage("暂无数据", time: 1, block: {})
                }
            }else{
                Utils.showHUDWithMessage(error.localizedDescription, time: 2, block: {})
            }
        }
    }
    
   
    
    //MARK:配置视图
    func configMainView(){
        //配置滑动视图
        self.containerView.contentOffset = CGPointMake(0, 0)
        self.containerView.contentSize = CGSizeMake(Utils.screenWidth * 3, 0)
        self.containerView.showsHorizontalScrollIndicator = true
        self.containerView.pagingEnabled = true
        self.view.addSubview(self.containerView)
        self.containerView.snp_makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.size.equalToSuperview()
        }
        //饼视图设置
        self.pieViewChartController.view.frame = CGRectMake(0, 0, Utils.screenWidth, Utils.screenHeight - 64)
        self.pieViewChartController.dataSource = self.dataSource
        self.pieViewChartController.configDataSource()
        self.containerView.addSubview(self.pieViewChartController.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
