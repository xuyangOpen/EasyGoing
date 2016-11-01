//
//  PieViewController.swift
//  EasyGoing
//
//  Created by King on 16/10/10.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit
import Charts

class PieViewController: UIViewController {

    //饼状图
    let pieChartView = PieChartView()
    //数据源
    var dataSource = [TimeLineRecord]()
    //创建一个分类的空字典，key表示消费项目  value表示数量
    var categoryDictionary = Dictionary<String, Int>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
    }

    //MARK:配置数据源
    func configDataSource(){
        for record in self.dataSource{
            //判断分类字典是否包含当前parentId
            if !self.categoryDictionary.keys.contains(record.parentName){
                self.categoryDictionary[record.parentName] = 1
            }else{
                self.categoryDictionary[record.parentName] = self.categoryDictionary[record.parentName]! + 1
            }
        }
        print(self.categoryDictionary)
    }
    
    //MARK:配置饼状视图
    func configPieChartView(){
        self.view.addSubview(self.pieChartView)
        self.pieChartView.snp_makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSizeMake(300, 300))
        }
        //基本样式设置
        self.pieChartView.setExtraOffsets(left: 30, top: 0, right: 30, bottom: 0)////饼状图距离边缘的间隙
        self.pieChartView.usePercentValuesEnabled = true//是否根据所提供的数据, 将显示数据转换为百分比格式
        self.pieChartView.dragDecelerationEnabled = true//拖拽饼状图后是否有惯性效果
        self.pieChartView.drawSliceTextEnabled = true//是否显示区块文本
        
        //设置饼状图中间的空心样式
        self.pieChartView.drawHoleEnabled = true//饼状图是否是空心
        self.pieChartView.holeRadiusPercent = 0.5//空心半径占比
        self.pieChartView.holeColor = UIColor.clearColor()//空心颜色
        self.pieChartView.transparentCircleRadiusPercent = 0.52//半透明空心半径占比
        self.pieChartView.transparentCircleColor = UIColor.whiteColor()//半透明空心的颜色
        
        //设置饼状图中心的文本
        if self.pieChartView.isDrawHoleEnabled {
            self.pieChartView.drawCenterTextEnabled = true//是否显示中间文字
            //普通文本
//            self.pieChartView.centerText = @"饼状图";//中间文字
            //设置富文本
            let centerText = NSMutableAttributedString.init(string: "消费项目")
            centerText.setAttributes([NSFontAttributeName:UIFont.boldSystemFontOfSize(13),NSForegroundColorAttributeName:UIColor.orangeColor()], range: NSMakeRange(0, centerText.length))
            self.pieChartView.centerAttributedText = centerText
        }
        
        // 设置饼状图描述
        self.pieChartView.descriptionText = "消费项目统计图例"
        self.pieChartView.descriptionFont = UIFont.systemFontOfSize(10)
        self.pieChartView.descriptionTextColor = UIColor.grayColor()
        
        // 设置饼状图图例样式
        self.pieChartView.legend.maxSizePercent = 1//图例在饼状图中的大小占比, 这会影响图例的宽高
        self.pieChartView.legend.formToTextSpace = 5//文本间隔
        self.pieChartView.legend.font = UIFont.systemFontOfSize(10)//字体大小
        self.pieChartView.legend.textColor = UIColor.grayColor()//字体颜色
//        self.pieChartView.legend.position = .BelowChartCenter//图例在饼状图中的位置
        self.pieChartView.legend.orientation = .Horizontal
        self.pieChartView.legend.verticalAlignment = .Bottom
        self.pieChartView.legend.form = .Circle//图示样式: 方形、线条、圆形
        self.pieChartView.legend.formSize = 12//图示大小
    }
    
    //MARK:配置饼状图的数据
//    func setPieChartViewData() -> PieChartData{
//        //饼状图总块数
////        let count = self.categoryDictionary.count
//        var yVals = [BarChartDataEntry]()
//        var times = 0
//        //每块区域的数据
//        for key in self.categoryDictionary.keys{
//            let rate = Double(self.categoryDictionary[key]!) / Double(self.dataSource.count)
//            let entry = BarChartDataEntry.init(value: rate, xIndex: times)
//            times += 1
//            yVals.append(entry)
//        }
//        //每块区域的数据
//        var xVals = [String]()
//        for key in self.categoryDictionary.keys{
//            xVals.append(key)
//        }
//        //dataSet
//        let dataSet = PieChartDataSet.init(yVals: yVals, label: "")
//        dataSet.drawValuesEnabled = true//是否绘制显示数据
//        var colors = [UIColor]()
//        colors.appendContentsOf(ChartColorTemplates.vordiplom())
////        colors.addObjectsFromArray(ChartColorTemplates.vordiplom())
////        colors.addObjectsFromArray(ChartColorTemplates.joyful())
////        colors.addObjectsFromArray(ChartColorTemplates.colorful())
////        colors.addObjectsFromArray(ChartColorTemplates.liberty())
////        colors.addObjectsFromArray(ChartColorTemplates.pastel())
////        colors.addObject(UIColor.init(red: 51/255.0, green: 181/255.0, blue: 229/255.0, alpha: 1.0))
//        dataSet.colors = colors
//        
//        
//        
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
