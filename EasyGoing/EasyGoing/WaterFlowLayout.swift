//
//  WaterFlowLayout.swift
//  EasyGoing
//
//  Created by King on 16/9/21.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

//MARK: 瀑布流协议
protocol WaterFlowLayoutDelegate {
    //获取图片的高度
    func heightForItemIndexPath(indexPath:NSIndexPath) -> CGFloat
}

class WaterFlowLayout: UICollectionViewFlowLayout {

    //item的大小
    var cellSize:CGSize?
    //内边距
    var sectionInsets:UIEdgeInsets?
    //间距
    var insertItemSpacing:CGFloat?
    //列数
    var numberOfColumn:Int?
    //返回图片高度的代理
    var delegate:WaterFlowLayoutDelegate?
    
    //所有item的数量
    var numberOfItems:Int?
    //保存每一列高度的数组
    lazy var columnHeights:NSMutableArray = NSMutableArray()
    //保存item属性的数组
    lazy var itemAttributes:[UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
    
    
    //MARK:获取最长列索引
    func indexForLongestColumn() -> Int{
        //记录索引
        var longestIndex = 0
        // 记录当前最长列高度
        var longestHeight:CGFloat = 0.0
        //判断目前哪一列是最长的列
        for i in 0..<(self.numberOfColumn)! {
            //取出高度
            let height = self.columnHeights[i] as! CGFloat
            if height > longestHeight {
                longestHeight = height
                //记录索引
                longestIndex = i
            }
        }
        return longestIndex
    }
    
    //MARK:获取最短列索引
    func indexForShortestColumn() -> Int{
        //记录索引
        var shortestIndex = 0
        //记录最短列高度
        var shortestHeight = CGFloat.max
        //返回目前哪一列是最短列的下标
        for i in 0..<(self.numberOfColumn)! {
            //取出高度
            let height = self.columnHeights[i] as! CGFloat
            if height < shortestHeight {
                shortestHeight = height
                shortestIndex = i
            }
        }
        return shortestIndex
    }
    
    //MARK:准备布局时，计算相关数据
    override func prepareLayout() {
        super.prepareLayout()
        
        //循环添加top高度
        for i in 0..<(self.numberOfColumn)! {
            self.columnHeights[i] = (self.sectionInsets!.top)
        }
        
        //获取item数量
        self.numberOfItems = self.collectionView?.numberOfItemsInSection(0)
        
        //循环计算每一个item的x y width height
        for i in 0..<(self.numberOfItems)! {
            //获取最短列
            let shortIndex = self.indexForShortestColumn()
            //获取最短列高度
            let shortsH = self.columnHeights[shortIndex] as! CGFloat
            //x的值 = 左内边距 + (item的宽度+间距)*列数
            let detalX = (self.sectionInsets?.left)! + ((self.cellSize?.width)! + self.insertItemSpacing!) * CGFloat(shortIndex)
            //y的值 = 当前高度 + 间距
            let detalY = shortsH + self.insertItemSpacing!
            //构建一个indexPath
            let indexPath = NSIndexPath.init(forItem: i, inSection: 0)
            
            //Height
            var itemHeight:CGFloat = 0.0
            if self.delegate != nil{
                itemHeight = (self.delegate?.heightForItemIndexPath(indexPath))!
            }
            //保存item frame属性的对象
            let attribute = UICollectionViewLayoutAttributes.init(forCellWithIndexPath: indexPath)
            attribute.frame = CGRectMake(detalX, detalY, self.cellSize!.width, itemHeight)
            //放入数组中
            self.itemAttributes.append(attribute)
            //更新高度
            self.columnHeights[shortIndex] = detalY + itemHeight
        }
        
    }
    
    //MARK:计算contentSize -->内容的总高度
    override func collectionViewContentSize() -> CGSize {
        //获取高度最高的列
        let longestIndex = self.indexForLongestColumn()
        //获得最高列的高度
        let longestH = self.columnHeights[longestIndex] as! CGFloat
        
        //计算contentSize
        var contentSize = self.collectionView?.frame.size
        contentSize?.height = longestH + (self.sectionInsets?.bottom)!
        
        return contentSize!
    }
    
    //MARK:返回当前item的数组
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.itemAttributes
    }
    
    
    
    
    
    
}
