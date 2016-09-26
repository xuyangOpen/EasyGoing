//
//  HomeViewController.swift
//  EasyGoing
//
//  Created by King on 16/9/21.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController,WaterFlowLayoutDelegate,UICollectionViewDelegate,UICollectionViewDataSource {
    
    let flowLayout = WaterFlowLayout()
    
    var homeCollectionView:UICollectionView?
    //保存每个item配置的数组
    lazy var itemConfigs = [WaterFlowModel]()
    //背景图片
    let backgroundImageView = UIImageView()
    
    //复用cell的identifier
    let identifierArray = ["CAGradientLayerCell","EasingCell","ClockCell","EmitterSnowCell","MusicBarCell","WaterWaveCell"]
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //隐藏导航栏
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //背景图片
        self.backgroundImageView.image = UIImage.init(named: "show2.jpg")
        self.backgroundImageView.frame = self.view.bounds
        self.backgroundImageView.contentMode = .ScaleAspectFill

        //设置布局
        flowLayout.delegate = self
        flowLayout.insertItemSpacing = 10.0   //间距为10
        flowLayout.sectionInsets = UIEdgeInsetsMake(10, 10, 10, 10)         //内边距
        flowLayout.numberOfColumn = 2       //2列
        //item宽度 = （屏幕宽 - 列数+1倍间距）/ 列数
        let itemWidth = (Utils.screenWidth-CGFloat((flowLayout.numberOfColumn!+1))*CGFloat(flowLayout.insertItemSpacing!)) / CGFloat(flowLayout.numberOfColumn!)
        
        //item的宽度确定  高度由代理方法返回，所以暂时和宽度一致
        flowLayout.cellSize = CGSizeMake(itemWidth, itemWidth)
        //设置collectionView
        self.homeCollectionView = UICollectionView.init(frame: self.view.bounds, collectionViewLayout: self.flowLayout)
        self.homeCollectionView!.collectionViewLayout = self.flowLayout
        //给collectionview设置背景图片
        self.homeCollectionView!.backgroundView = self.backgroundImageView
        self.homeCollectionView!.delegate = self
        self.homeCollectionView!.dataSource = self
        self.view.addSubview(self.homeCollectionView!)
        
        
        //注册cell
        for identifier in self.identifierArray {
            self.homeCollectionView!.registerClass(WaterFlowCell.self, forCellWithReuseIdentifier: identifier)
        }
        //注册一个复用的空白cell
        self.homeCollectionView?.registerClass(WaterFlowCell.self, forCellWithReuseIdentifier: "waterFlowCell")
        
        //初始化数组
        for i in 0..<20 {
            let model = WaterFlowModel()
            if i == 0 {
                model.style = UICollectionStyle.CAGradientLayer
            }else if i == 1{
                model.style = UICollectionStyle.Easing
            }else if i == 2{
                model.style = UICollectionStyle.Clock
            }else if i == 3{
                model.style = UICollectionStyle.EmitterSnow
            }else if i == 4{
                model.style = UICollectionStyle.MusicBar
            }else if i == 5{
                model.style = UICollectionStyle.WaterWave
            }else{
                model.style = UICollectionStyle.None
            }
            model.itemWidth = itemWidth
            model.itemHeight = CGFloat(arc4random_uniform(100)+100)
            model.itemColor = UIColor.init(red: CGFloat(arc4random_uniform(255))/255.0, green: CGFloat(arc4random_uniform(255))/255.0, blue: CGFloat(arc4random_uniform(255))/255.0, alpha: 1.0)
            self.itemConfigs.append(model)
        }
    }
    
    //MARK:返回item高度的代理方法
    func heightForItemIndexPath(indexPath: NSIndexPath) -> CGFloat {
        return 150
  //      return self.itemHeights[indexPath.row].itemHeight
    }
    
    //MARK:UICollectionView的代理方法
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.itemConfigs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //判断是否有类型
        if self.itemConfigs[indexPath.row].style?.rawValue != 0 {
            let item = collectionView.dequeueReusableCellWithReuseIdentifier(self.identifierArray[self.itemConfigs[indexPath.row].style!.rawValue-1], forIndexPath: indexPath) as! WaterFlowCell
            item.setModel(self.itemConfigs[indexPath.row])
            return item
        }else{
            //空白item
            let item = collectionView.dequeueReusableCellWithReuseIdentifier("waterFlowCell", forIndexPath: indexPath)
            return item
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! WaterFlowCell
        switch cell.style {
        case .CAGradientLayer:break
        case .Easing:
            self.navigationController?.pushViewController(TimeLineController(), animated: true)
        default: break
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
