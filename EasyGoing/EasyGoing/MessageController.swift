//
//  MessageController.swift
//  EasyGoing
//
//  Created by King on 16/11/25.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

class MessageController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    let messageTableView = UITableView()
    var messages = [String]()
    let msgIdentifier = "msgCell"
    //线程队列
    let operation = NSOperationQueue()
    var previewOperation:NSOperation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置UITableView
        self.configMsgTableView()
    }
    
    //MARK:设置UITableview
    func configMsgTableView(){
        self.messageTableView.separatorStyle = .None
        self.messageTableView.delegate = self
        self.messageTableView.dataSource = self
        self.messageTableView.showsVerticalScrollIndicator = false
        self.messageTableView.showsHorizontalScrollIndicator = false
        //将UITableView的用户操作禁止，防止用户滑动影响地图交互
        self.messageTableView.userInteractionEnabled = false
        self.messageTableView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(self.messageTableView)
        self.messageTableView.snp_makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.size.equalToSuperview()
        }
        self.messageTableView.reloadData()
        
        self.operation.maxConcurrentOperationCount = 1
        
    }
    
    //MARK:添加一条消息
    func addMessage(message: String){
        if self.messages.count == 0 {
            //当消息队列为空时，添加7条空数据，方便cell从底部开始加载
            for _ in 0..<7 {
                self.messages.append(" ")
            }
            self.messages.append(message)
            self.messageTableView.reloadData()
            self.messageTableView.scrollToRowAtIndexPath(NSIndexPath.init(forRow: 7, inSection: 0), atScrollPosition: .Bottom, animated: false)
        }else{
            //添加一个线程
            let block = NSBlockOperation.init(block: {
                //延时0.25秒
                let time: NSTimeInterval = 0.25
                let delay = dispatch_time(DISPATCH_TIME_NOW,
                    Int64(time * Double(NSEC_PER_SEC)))
                dispatch_after(delay, dispatch_get_main_queue()) {
                    self.executeMessage(message)
                }
            })
            if self.previewOperation == nil {
                self.previewOperation = block
            }else{
                block.addDependency(self.previewOperation!)
                self.previewOperation = block
            }
            self.operation.addOperation(block)
        }
    }
    
    //MARK:最后一条消息
    func addLastMessage(message: String){
        self.addMessage(message)
        self.operation.addObserver(self, forKeyPath: "operations", options: .New, context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if object! as! NSObject == self.operation && keyPath! == "operations" {
            if self.operation.operations.count == 0 {
                //先移除观察者对象
                self.operation.removeObserver(self, forKeyPath: "operations")
                //等3秒后最后一条消息显示完毕，页面释放
                let time: NSTimeInterval = 3
                let delay = dispatch_time(DISPATCH_TIME_NOW,
                                          Int64(time * Double(NSEC_PER_SEC)))
                dispatch_after(delay, dispatch_get_main_queue()) {
                    print("所有消息执行完毕")
                    self.operation.cancelAllOperations()
                    self.previewOperation = nil
                    self.view.removeFromSuperview()
                    self.messages.removeAll()
                }
            }
        }
    }
    
    //MARK:执行消息
    func executeMessage(message: String){
        if self.messages.count == 0 {
            //当消息为空时，添加一条消息
            self.messages.append(message)
            self.messageTableView.reloadData()
        }else{
            //当消息不为空时，动态添加一条消息，并给上条消息发送隐藏的信息
            self.messages.append(message)
            self.messageTableView.insertRowsAtIndexPaths([NSIndexPath.init(forRow: self.messages.count - 1, inSection: 0)], withRowAnimation: .Bottom)
            self.messageTableView.scrollToRowAtIndexPath(NSIndexPath.init(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
            //将上条信息开始启用定时器
            let cell = self.messageTableView.cellForRowAtIndexPath(NSIndexPath.init(forRow: self.messages.count - 2, inSection: 0)) as! MessageCell
            cell.startTimer()
        }
        
    }
    
    //MARK:UITableview的代理方法
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = MessageCell.init(style: .Default, reuseIdentifier: msgIdentifier)
        cell.addTitle(self.messages[indexPath.row])
//        print("当前初始化第\(indexPath.row)个cell")
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height = Utils.heightForText(self.messages[indexPath.row], size: CGSizeMake(self.view.frame.size.width - 10, CGFloat.max), font: UIFont.systemFontOfSize(12))
        return height
    }
    
    deinit{
        print("消息控制器释放")
    }
    
}
