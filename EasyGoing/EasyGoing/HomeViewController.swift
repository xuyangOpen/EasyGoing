//
//  HomeViewController.swift
//  EasyGoing
//
//  Created by King on 16/9/21.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    let flowLayout = UICollectionViewFlowLayout()
    
    var homeCollectionView:UICollectionView?
    //保存每个item配置的数组
    lazy var itemConfigs = [WaterFlowModel]()
    //背景图片
    let backgroundImageView = UIImageView()
    
    //复用cell的identifier
    let identifierArray = ["PhotoCell","TimeLineCell","ClockCell","SportCell","MapCell","RandomCell"]
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //隐藏导航栏
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //背景颜色
        self.view.backgroundColor = UIColor.whiteColor()
        self.automaticallyAdjustsScrollViewInsets = false
        //设置布局
        flowLayout.minimumLineSpacing = 5
        flowLayout.minimumInteritemSpacing = 5
        flowLayout.sectionInset = UIEdgeInsetsMake(5, 0, 5, 0)
        flowLayout.headerReferenceSize = CGSizeMake(Utils.screenWidth, Utils.scaleFloat(240))
        //item宽度 = （屏幕宽 - 1倍间距）/ 列数
        let itemWidth = (Utils.screenWidth-5)/2.0
        
        //item的宽度确定  高度由代理方法返回，所以暂时和宽度一致
        flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth)
        //设置collectionView
        self.homeCollectionView = UICollectionView.init(frame: self.view.bounds, collectionViewLayout: self.flowLayout)
        self.homeCollectionView!.collectionViewLayout = self.flowLayout
        //给collectionview设置背景图片
        self.homeCollectionView!.backgroundColor = UIColor.whiteColor()
        self.homeCollectionView!.delegate = self
        self.homeCollectionView!.dataSource = self
        self.view.addSubview(self.homeCollectionView!)
        
        
        //注册cell
        for identifier in self.identifierArray {
            self.homeCollectionView!.registerClass(WaterFlowCell.self, forCellWithReuseIdentifier: identifier)
        }
        //注册一个复用的空白cell
        self.homeCollectionView?.registerClass(WaterFlowCell.self, forCellWithReuseIdentifier: "waterFlowCell")
        //注册头视图
        self.homeCollectionView?.registerClass(HomeHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "homeHeaderView")
        
        //初始化数组
        for i in 0..<6 {
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
        case .CAGradientLayer:
            self.navigationController?.pushViewController(PhotoViewController(), animated: true)
            break
        case .Easing://小金库
            self.navigationController?.pushViewController(TimeLineController(), animated: true)
        case .MusicBar://目的地
            self.navigationController?.pushViewController(DestinationViewController(), animated: true)
        default:
            Utils.showMessageOnView(self.view, message: "敬请期待", time: 1, block: nil)
            break
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "homeHeaderView", forIndexPath: indexPath) as! HomeHeaderView
        header.configHeaderView(["ad1.jpg","ad2.jpg","ad3.jpg","ad4.jpg","ad5.jpg"])
        return header
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -20 {
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
        }else{
           UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
