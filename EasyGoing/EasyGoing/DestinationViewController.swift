//
//  WhateverController.swift
//  EasyGoing
//
//  Created by King on 16/8/29.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit
import AVOSCloud
import AudioToolbox

typealias completeClosure = () -> Void

class DestinationViewController: UIViewController,BMKMapViewDelegate,BMKLocationServiceDelegate,UISearchBarDelegate,BMKSuggestionSearchDelegate,SearchControllerDelegate,BMKGeoCodeSearchDelegate,BMKRouteSearchDelegate {

    ///地图定位类
    var mapView: BMKMapView?
    let locService = BMKLocationService()
    let mapSearch = BMKSuggestionSearch()   //搜索类
    let geocodesearch = BMKGeoCodeSearch()  //地理编码类
    let routeSearch = BMKRouteSearch()      //路线规划类
    //用户当前位置
    var userCurrentLocation = BMKUserLocation()
    //起点反向编码位置信息
    var startPoint : BMKReverseGeoCodeResult?
    //终点反向编码位置
    var endPoint : BMKReverseGeoCodeResult?
    //当前反向编码模式  ： 起点  终点  start end
    var currentGeoCodeModel = ""
    //当前大头针模式  导航时不显示大头针，定位时显示大头针  location  driving
    var annonationModel = ""
    //是否开启位置计算模式
    var isStartDistanceCalculate = false
    
    //大头针指向的地址
    var annotationTitle = ""
    //选择提示距离的控制器
    let distanceVC = SelectPromptDistanceController()
    //当前提示距离，默认是300
    var promptDistance = 300
    //当前两点之前的距离
    var currentDistance:Double = 0
    //是否已经开启了距离提示
    var isOpenUp = false
    //是否已经发送了本地通知
    var isSendLocalNotification = false
    //是否需要置空代理，释放内存
    var isNeedReleaseMemory = true
    
    //定位到用户当前位置的按钮
    let locationButton = UIButton()
    //搜索条
    let searchBar = UISearchBar()
    //搜索控制器
    let searchController = SearchController()
    //消息控制器
    let messageController = MessageController()
    //底部视图
    let bottomView = UIView.init(frame: CGRectMake(0, Utils.screenHeight, Utils.screenWidth, Utils.scaleFloat(100)))
    
    let startLabel = UILabel()      //起点label
    let endLabel = UILabel()        //终点label
    let directionImageView = RightArrowView()   //中间方向箭头
    let resetButton = UIButton()   //重新计算路线的按钮
    let setPromptButton = UIButton()   //设置提示距离的按钮
    let setMusicButton = UIButton()     //设置提示音乐的按钮
    let currentDistanceLabel = UILabel()        //当前距离label
    let promptLabel = UILabel()                 //提示label
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //显示导航栏
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        //状态栏为黑色
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
        mapView?.viewWillAppear()
        //重置需要释放内存
        self.isNeedReleaseMemory = true
    }
//    除非页面销毁，视图时刻运行，包括后台
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        mapView?.viewWillDisappear()
        
        if !self.isNeedReleaseMemory {//当前页面跳转，不需要释放内存
            mapView?.delegate = self // 不用时，置nil
            locService.delegate = self
            mapSearch.delegate = self
            geocodesearch.delegate = self
            routeSearch.delegate = self
        }else{//当前页面即将pop，释放内存
            mapView?.delegate = nil // 不用时，置nil
            locService.delegate = nil
            mapSearch.delegate = nil
            geocodesearch.delegate = nil
            routeSearch.delegate = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "地图"
        self.view.backgroundColor = UIColor.whiteColor()
        
        //当前默认的提示距离
        self.promptDistance = AVUser.currentUser()?.objectForKey("destinationDistance") as! Int
        
        mapView = BMKMapView(frame: CGRectMake(0, 108, self.view.bounds.width, self.view.bounds.height - 108))
        //代理设置
        mapView?.delegate = self // 此处记得不用的时候需要置nil，否则影响内存的释放
        locService.delegate = self
        mapSearch.delegate = self
        geocodesearch.delegate = self
        routeSearch.delegate = self
        mapView?.showMapScaleBar = true
        //打开定位服务
        locService.startUserLocationService()
        //设置后台
        locService.allowsBackgroundLocationUpdates = true
        
        mapView?.showsUserLocation = false
        mapView?.userTrackingMode = BMKUserTrackingModeFollow
        mapView?.showsUserLocation = true
        mapView?.trafficEnabled = true
        //级别是3-21  级别越高，地图显示越详细
        mapView?.zoomLevel = 15
        self.view.addSubview(mapView!)
        
        //设置UISearchBar
        self.configSearchBar()
        //设置底部视图
        self.configBottomView()
        //设置定位到当前位置的按钮
        self.configLocationButton()
    }
    
    //MARK:定位到当前位置的按钮
    func configLocationButton(){
        self.locationButton.setImage(UIImage.init(named: "location"), forState: .Normal)
        self.locationButton.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0)
        self.mapView?.addSubview(self.locationButton)
        self.locationButton.addTarget(self, action: #selector(showCurrentLocation), forControlEvents: .TouchUpInside)
        self.locationButton.snp_makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-10)
            make.right.equalToSuperview().offset(-10)
            make.size.equalTo(CGSizeMake(Utils.scaleFloat(35), Utils.scaleFloat(35)))
        }
    }
    
    //MARK:将当前位置显示到地图中间
    func showCurrentLocation(){
        mapView?.setCenterCoordinate(self.userCurrentLocation.location.coordinate, animated: true)
    }
    
    //MARK:设置UISearchBar
    func configSearchBar(){
        self.searchBar.frame = CGRectMake(0, 64, Utils.screenWidth, 44)
        self.searchBar.center.x = self.view.center.x
        self.searchBar.placeholder = "搜索目的地"
        self.searchBar.delegate = self
        self.searchBar.tintColor = Utils.allTintColor
        self.searchBar.backgroundColor = UIColor.whiteColor()
        self.searchBar.searchBarStyle = .Minimal
        self.view.addSubview(self.searchBar)
    }
    
    //MARK:设置底部视图
    func configBottomView(){
        self.bottomView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.bottomView)
        //中间视图
        self.bottomView.addSubview(self.directionImageView)
        
        self.directionImageView.frame = CGRectMake((self.bottomView.frame.width - Utils.scaleFloat(80))/2.0, Utils.scaleFloat(20), Utils.scaleFloat(80), Utils.scaleFloat(10))

        //当前距离label
        self.currentDistanceLabel.text = "距离：xx千米"
        self.currentDistanceLabel.textColor = UIColor.blackColor()
        self.currentDistanceLabel.textAlignment = .Center
        self.currentDistanceLabel.font = UIFont.systemFontOfSize(10)
        self.bottomView.addSubview(self.currentDistanceLabel)
        self.currentDistanceLabel.snp_makeConstraints { (make) in
            make.bottom.equalTo(self.directionImageView.snp_top).offset(-Utils.scaleFloat(5))
            make.centerX.equalTo(self.directionImageView)
        }
        //提示label
        self.promptLabel.text = "当距离小于300米时，将会开启提示"
        self.promptLabel.textColor = UIColor.blackColor()
        self.promptLabel.textAlignment = .Center
        self.promptLabel.font = UIFont.systemFontOfSize(10)
        self.promptLabel.numberOfLines = 0
        self.bottomView.addSubview(self.promptLabel)
        self.promptLabel.snp_makeConstraints { (make) in
            make.centerX.equalTo(self.directionImageView)
            make.top.equalTo(self.directionImageView.snp_bottom).offset(Utils.scaleFloat(5))
            make.width.equalTo(self.directionImageView.frame.width*2)
        }
        //起点label
        self.startLabel.textColor = UIColor.blackColor()
        self.startLabel.textAlignment = .Center
        self.startLabel.font = UIFont.boldSystemFontOfSize(16)
        self.bottomView.addSubview(self.startLabel)
        self.startLabel.snp_makeConstraints { (make) in
            make.left.equalToSuperview().offset(Utils.scaleFloat(20))
            make.centerY.equalTo(self.directionImageView)
            make.right.equalTo(self.directionImageView.snp_left).offset(-Utils.scaleFloat(10))
        }
        //终点label
        self.endLabel.textColor = UIColor.blackColor()
        self.endLabel.font = UIFont.boldSystemFontOfSize(16)
        self.endLabel.textAlignment = .Center
        self.bottomView.addSubview(self.endLabel)
        self.endLabel.snp_makeConstraints { (make) in
            make.right.equalToSuperview().offset(-Utils.scaleFloat(20))
            make.centerY.equalTo(self.directionImageView)
            make.left.equalTo(self.directionImageView.snp_right).offset(Utils.scaleFloat(10))
        }
        //设置重新规划路线的按钮
        let averageWidth = (Utils.screenWidth-80)/3.0//每个按钮的平均宽
        self.resetButton.setTitle("更新规划路线", forState: .Normal)
        self.resetButton.setTitleColor(Utils.allTintColor, forState: .Normal)
        self.resetButton.titleLabel?.font = UIFont.systemFontOfSize(12)
        self.resetButton.layer.borderColor = Utils.allTintColor.CGColor
        self.resetButton.layer.borderWidth = 1
        self.resetButton.layer.cornerRadius = self.startLabel.frame.height/2.0
        self.resetButton.layer.masksToBounds = true
        self.resetButton.addTarget(self, action: #selector(updateUserRoute), forControlEvents: .TouchUpInside)
        self.bottomView.addSubview(self.resetButton)
        self.resetButton.snp_makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-5)
            make.size.equalTo(CGSizeMake(averageWidth, Utils.scaleFloat(28)))
        }
        //设置提示距离按钮
        self.setPromptButton.setTitle("设置提示距离", forState: .Normal)
        self.setPromptButton.setTitleColor(Utils.allTintColor, forState: .Normal)
        self.setPromptButton.titleLabel?.font = UIFont.systemFontOfSize(12)
        self.setPromptButton.layer.borderColor = Utils.allTintColor.CGColor
        self.setPromptButton.layer.borderWidth = 1
        self.setPromptButton.addTarget(self, action: #selector(setPromptDistance), forControlEvents: .TouchUpInside)
        self.bottomView.addSubview(self.setPromptButton)
        self.setPromptButton.snp_makeConstraints { (make) in
            make.left.equalTo(self.resetButton.snp_right).offset(20)
            make.bottom.equalToSuperview().offset(-5)
            make.size.equalTo(self.resetButton)
        }
        //设置提示音乐的按钮
        self.setMusicButton.setTitle("设置提示音乐", forState: .Normal)
        self.setMusicButton.setTitleColor(Utils.allTintColor, forState: .Normal)
        self.setMusicButton.titleLabel?.font = UIFont.systemFontOfSize(12)
        self.setMusicButton.layer.borderColor = Utils.allTintColor.CGColor
        self.setMusicButton.layer.borderWidth = 1
        self.setMusicButton.addTarget(self, action: #selector(setPromptMusic), forControlEvents: .TouchUpInside)
        self.bottomView.addSubview(self.setMusicButton)
        self.setMusicButton.snp_makeConstraints { (make) in
            make.left.equalTo(self.setPromptButton.snp_right).offset(20)
            make.bottom.equalToSuperview().offset(-5)
            make.size.equalTo(self.resetButton)
        }
    }
    
    //MARK:更新规划路线
    func updateUserRoute(){
        //防止重复点击
        self.resetButton.enabled = false
        //先清除之前的路径和大头针
        if mapView?.annotations.count > 0 {
            mapView?.removeAnnotations(mapView?.annotations)
        }
        if mapView?.overlays.count > 0  {
            mapView?.removeOverlays(mapView?.overlays)
        }
        //先在地图上放置大头针
        self.choosePlaceByCoordinate(CGPointMake(CGFloat(self.endPoint!.location.latitude), CGFloat(self.endPoint!.location.longitude)), placeName: self.annotationTitle)
        //开始规划路线
        self.planningTheRoute()
    }
    
    //MARK:设置提示距离
    func setPromptDistance(){
        distanceVC.distance = self.promptDistance
        distanceVC.chooseDistance = { [weak self] (distance) in
            self?.promptDistance = distance
            if Double(distance) > self?.currentDistance {
                //提示关闭
                self?.isOpenUp = false
                self?.alertMessage("提示", message: "当前位置与目的地的距离小于提示距离",showOnVC: self!.distanceVC, complete: nil)
                self?.promptLabel.text = "未开启提示"
            }else{
                //开启提示
                self?.isOpenUp = true
                if distance >= 1000  {
                    self?.promptLabel.text = String.init(format: "当距离小于%.0lf千米时，将会开启提示", Double(distance)/1000.0)
                }else{
                    self?.promptLabel.text = "当距离小于\(self!.promptDistance)米时，将会开启提示"
                }
            }
        }
        //当前页面跳转，不需要释放内存
        self.isNeedReleaseMemory = false
        self.navigationController?.pushViewController(distanceVC, animated: true)
    }
    
    //MARK:设置提示音乐
    func setPromptMusic(){
        let musicVC = SelectPromptMusicViewController()
        //当前页面跳转，不需要释放内存
        self.isNeedReleaseMemory = false
        
        self.navigationController?.pushViewController(musicVC, animated: true)
    }
    
    //MARK:UISearchBarDelegate代理方法
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        //如果底部视图出现了的话，将其隐藏
        self.bottomView.frame = CGRectMake(0, Utils.screenHeight, Utils.screenWidth, Utils.scaleFloat(100))
        self.mapView?.frame = CGRectMake(0, 108, self.view.bounds.width, self.view.bounds.height - 108)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.searchBar.showsCancelButton = true
        UIView.animateWithDuration(0.25) {
            self.searchBar.frame = CGRectMake(0, 20, Utils.screenWidth, 44)
        }
        //添加搜索控制器
        self.searchController.view.frame = self.view.bounds
        self.searchController.delegate = self
        if self.searchController.showModel != "" {
            self.searchController.showModel = "history"
        }
        self.view.insertSubview(self.searchController.view, belowSubview: self.searchBar)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        if self.endPoint != nil {
            //开始规划路线时，底部视图出现
            self.bottomView.frame = CGRectMake(0, Utils.screenHeight - Utils.scaleFloat(100), Utils.screenWidth, Utils.scaleFloat(100))
            self.mapView?.frame = CGRectMake(0, 108, self.view.bounds.width, self.view.bounds.height - 108 - Utils.scaleFloat(100))
        }
        
        self.searchBar.showsCancelButton = false
        self.searchBar.resignFirstResponder()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        UIView.animateWithDuration(0.25) {
            self.searchBar.frame = CGRectMake(0, 64, Utils.screenWidth, 44)
        }
        //移除搜索控制器
        self.searchController.view.removeFromSuperview()
    }
    //MARK:点击键盘搜索按钮
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar(self.searchBar, textDidChange: "")
    }

    //在此方法中调用百度地图的搜索方法
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let result = Utils.isNullString(self.searchBar.text!)
        if !result.0 {
            let option = BMKSuggestionSearchOption()
            option.keyword = result.1
            option.cityname = ""
             self.searchController.showModel = ""
            mapSearch.suggestionSearch(option)
        }else{
            self.searchController.showModel = "history"
        }
    }
    
    //MARK:搜索结果回调代理方法
    func onGetSuggestionResult(searcher: BMKSuggestionSearch!, result: BMKSuggestionResult!, errorCode error: BMKSearchErrorCode) {
        
        if error == BMK_SEARCH_NO_ERROR {
            self.searchController.dataSource.removeAll()
            for i in 0..<result.keyList.count {
                let searchModel = SearchModel()
                searchModel.placeKey = result.keyList[i] as! String
                searchModel.cityKey = result.cityList[i] as! String
                searchModel.districtKey = result.districtList[i] as! String
                //CLLocationCoordinate2D经纬度
                searchModel.ptInfo = result.ptList[i] as! NSValue
                self.searchController.dataSource.append(searchModel)
            }
        }
        self.searchController.refreshTableView()
    }
    
    //MARK: - 搜索控制器代理方法
    //MARK:地图添加大头针的方法
    func choosePlaceByCoordinate(point: CGPoint, placeName: String) {
        let item = BMKPointAnnotation()
        item.coordinate = CLLocationCoordinate2D.init(latitude: Double(point.x), longitude: Double(point.y))
        //添加大头针之前，先移除之前的大头针
        if mapView?.annotations.count > 0 {
            mapView?.removeAnnotations(mapView?.annotations)
        }
        //设置大头针模式
        self.annonationModel = "location"
        //设置当前模式为：普通定位模式 ，以免与设置大头针为地图中心的操作冲突
        mapView?.userTrackingMode = BMKUserTrackingModeHeading
        self.annotationTitle = placeName
        //添加新的大头针
        mapView?.addAnnotation(item)
        //设置地图使显示区域显示所有annotations,如果数组中只有一个则直接设置地图中心为annotation的位置
        mapView?.showAnnotations(mapView?.annotations, animated: true)
        
        self.searchBarCancelButtonClicked(self.searchBar)
    }
    
    //MARK:添加大头针视图处理方法
    func mapView(mapView: BMKMapView!, viewForAnnotation annotation: BMKAnnotation!) -> BMKAnnotationView! {
        if annotation is BMKPointAnnotation{
            let annotationView = BMKAnnotationView.init(annotation: annotation, reuseIdentifier: "annotation")
//            print("大头针的经纬度为 = \(annotation.coordinate)")
            if self.annonationModel == "location" {
                annotationView.image = UIImage.init(named: "annotation")
                annotationView.frame.size = CGSizeMake(30, 30)
                annotationView.paopaoView = BMKActionPaopaoView.init(customView: self.customViewWithTitle(false, title: self.annotationTitle))
                annotationView.setSelected(true, animated: true)
            }else if self.annonationModel == "driving"{
                let routeAnnotation = annotation as! RouteAnnotation
                if routeAnnotation.type == 0 {//起点
                    annotationView.image = nil//UIImage.init(named: "annotation")
                    annotationView.frame.size = CGSizeMake(30, 30)
                    annotationView.paopaoView = nil
                    //BMKActionPaopaoView.init(customView: self.customViewWithTitle(true,title: "起点"))
                }else if routeAnnotation.type == 1{//终点
                    annotationView.image = UIImage.init(named: "annotation")
                    annotationView.frame.size = CGSizeMake(30, 30)
                    annotationView.paopaoView = BMKActionPaopaoView.init(customView: self.customViewWithTitle(true,title: self.annotationTitle))
                }else{
                    let image = UIImage.init(named: "icon_direction@2x")
                    annotationView.image = image?.imageRotatedByDegrees(CGFloat(routeAnnotation.degree))
                    annotationView.frame.size = CGSizeMake(12, 12)
                }
            }
            return annotationView
        }
        return nil
    }
    
    //MARK:自定义大头针顶部的泡泡视图
    func customViewWithTitle(isStartOrEndPoint: Bool,title: String) -> UIView{
        //自定义大头针顶部视图
        let paopaoView = UIView()
        let titleLength = Utils.widthForText(title, size: CGSizeMake(CGFloat.max, 15), font: UIFont.systemFontOfSize(12))
        let btnLength = Utils.widthForText("设为目的地", size: CGSizeMake(CGFloat.max, 15), font: UIFont.systemFontOfSize(12))
        if isStartOrEndPoint {//如果是起点或者终点，则宽度为label宽度
            paopaoView.frame = CGRectMake(0, 0, titleLength + 10, 30)
        }else{
            paopaoView.frame = CGRectMake(0, 0, titleLength + btnLength + 20, 30)
        }
        paopaoView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0)
        //黑色的背景
        let back = UIImageView.init(frame: CGRectMake(0, 0, paopaoView.frame.width, 25))
        back.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
        back.layer.cornerRadius = 3
        paopaoView.addSubview(back)
        //放置标题
        let titleLabel = UILabel.init(frame: CGRectMake(5, 0, titleLength, 25))
        titleLabel.text = title
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = .Center
        titleLabel.font = UIFont.systemFontOfSize(12)
        titleLabel.userInteractionEnabled = true
        paopaoView.addSubview(titleLabel)
        
        if !isStartOrEndPoint {//如果是起点或者终点，则不显示设为目的地
            //分割线
            let line = UIImageView.init(frame: CGRectMake(CGRectGetMaxX(titleLabel.frame) + 5, 0, 0.5, 25))
            line.backgroundColor = UIColor.whiteColor()
            paopaoView.addSubview(line)
            
            //设为目的地
            let desLabel = UILabel.init(frame: CGRectMake(CGRectGetMaxX(line.frame) + 5, 0, btnLength, 25))
            desLabel.text = "设为目的地"
            desLabel.textColor = UIColor.whiteColor()
            desLabel.textAlignment = .Center
            desLabel.font = UIFont.systemFontOfSize(12)
            desLabel.userInteractionEnabled = true
            paopaoView.addSubview(desLabel)
            
            //添加轻点手势，规划路线
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(planningTheRoute))
            titleLabel.addGestureRecognizer(tap)
            desLabel.addGestureRecognizer(tap)
        }
        
        return paopaoView
    }
    
    //MARK:规划轨迹的代理方法
    func mapView(mapView: BMKMapView!, viewForOverlay overlay: BMKOverlay!) -> BMKOverlayView! {
        if overlay is BMKPolyline {
            let polylineView = BMKPolylineView.init(overlay: overlay)
//            polylineView.fillColor = UIColor.cyanColor().colorWithAlphaComponent(1)
            polylineView.strokeColor = Utils.colorWith(0, G: 51, B: 255).colorWithAlphaComponent(0.7)
            //Utils.colorWith(17, G: 182, B: 37).colorWithAlphaComponent(0.7)
            polylineView.lineWidth = 8.0
            polylineView.isFocus = false
            return polylineView
        }
        return nil
    }
    
    //MARK:设为目的地之后，规划路线
    func planningTheRoute(){
        //关闭距离计算模式
        self.isStartDistanceCalculate = false
        //检索当前经纬度，进行反向编码
        let coordination = userCurrentLocation.location
        if coordination == nil {
            Utils.showMessageOnView(self.view, message: "未获取到定位信息", time: 1.5, block: nil)
        }else{
            //加载消息控制器
            self.mapView!.addSubview(self.messageController.view)
            self.messageController.view.snp_makeConstraints(closure: { (make) in
                make.bottom.equalTo(self.mapView!.snp_centerY)
                make.left.equalToSuperview().offset(10)
                make.size.equalTo(CGSizeMake(Utils.scaleFloat(170), Utils.scaleFloat(100)))
            })
            
            let reverseGeocodeSearchOption = BMKReverseGeoCodeOption()
            reverseGeocodeSearchOption.reverseGeoPoint = coordination.coordinate
            //先起点反向编码
            self.currentGeoCodeModel = "start"
            if geocodesearch.reverseGeoCode(reverseGeocodeSearchOption) {
                self.messageController.addMessage("第一次反向编码开始...")
            }else{
                self.messageController.addLastMessage("第一次反向编码失败...")
            }
        }
    }
    
    //MARK:反向地理编码代理方法
    func onGetReverseGeoCodeResult(searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
        if error == BMK_SEARCH_NO_ERROR {
            //起点反向编码
            if self.currentGeoCodeModel == "start" {
                //编码模式改为终点
                self.currentGeoCodeModel = "end"
                //记录起点编码结果
                self.startPoint = result
                //终点反向编码模式
                let end = mapView?.annotations[0] as! BMKAnnotation
                let reverseGeocodeSearchOption = BMKReverseGeoCodeOption()
                reverseGeocodeSearchOption.reverseGeoPoint = end.coordinate
                if geocodesearch.reverseGeoCode(reverseGeocodeSearchOption) {
                    self.messageController.addMessage("第二次反向编码开始...")
                }else{
                    self.messageController.addLastMessage("第二次反向编码失败...")
                }
                
            }else if self.currentGeoCodeModel == "end"{
                //地理编码模式置空
                self.currentGeoCodeModel = ""
                //记录终点编码结果
                self.endPoint = result
                //开始规划驾车路线
                //起点
                let start = BMKPlanNode()
                start.name = self.startPoint!.addressDetail.streetName
                start.cityName = self.startPoint!.addressDetail.city
                start.pt = self.userCurrentLocation.location.coordinate
                //终点
                let end = BMKPlanNode()
                end.name = self.annotationTitle
                end.cityName = result.addressDetail.city
                end.pt = result.location
                //开始路线规划
                let drivingRouteSearchOption = BMKDrivingRoutePlanOption()
                drivingRouteSearchOption.from = start
                drivingRouteSearchOption.to = end
                drivingRouteSearchOption.drivingRequestTrafficType =
                BMK_DRIVING_REQUEST_TRAFFICE_TYPE_PATH_AND_TRAFFICE
                //BMK_DRIVING_REQUEST_TRAFFICE_TYPE_NONE
                if routeSearch.drivingSearch(drivingRouteSearchOption) {
                    self.messageController.addMessage("开始路线规划计算...")
                }else{
                    self.messageController.addLastMessage("路线规划失败")
                }
            }
        }
    }
    
    //MARK:路线规划代理方法
    func onGetDrivingRouteResult(searcher: BMKRouteSearch!, result: BMKDrivingRouteResult!, errorCode error: BMKSearchErrorCode) {
        //先移除所有大头针
        if mapView?.annotations.count > 0 {
            mapView?.removeAnnotations(mapView?.annotations)
        }
        //移除先前轨迹
        if mapView?.overlays.count > 0 {
            mapView?.removeOverlays(mapView?.overlays)
        }
        if error == BMK_SEARCH_NO_ERROR {
            self.messageController.addMessage("正在绘制地图...")
            
            let plan = result.routes[0] as! BMKDrivingRouteLine
            //计算路线方案中的路段数目
            let size = plan.steps.count
            var planPointCounts = 0
            for i in 0..<size {
                let transitStep = plan.steps[i] as! BMKDrivingStep
                if i == 0 {//起点
                    let item = RouteAnnotation()
                    item.coordinate = plan.starting.location
                    item.title = "起点"
                    item.type = 0
                    //当前大头针模式
                    self.annonationModel = "driving"
                    mapView?.addAnnotation(item)// 添加起点标注
                }else if i == size - 1{
                    let item = RouteAnnotation()
                    item.coordinate = plan.terminal.location
                    item.title = "终点"
                    item.type = 1
                    //当前大头针模式
                    self.annonationModel = "driving"
                    mapView?.addAnnotation(item)// 添加终点标注
                }
                //添加annotation节点
                let item = RouteAnnotation()
                item.coordinate = transitStep.entrace.location
                item.title = transitStep.entraceInstruction
                item.degree = Int(transitStep.direction) * 30
                item.type = 4
                //当前大头针模式
                self.annonationModel = "driving"
                mapView?.addAnnotation(item)
                //轨迹点总数累计
                planPointCounts += Int(transitStep.pointsCount)
            }
            // 添加途经点
            if plan.wayPoints.count > 0 {
                for tempNode in plan.wayPoints {
                    let item = RouteAnnotation()
                    item.coordinate = tempNode.pt
                    item.type = 5
                    item.title = tempNode.name
                    mapView?.addAnnotation(item)
                }
            }
            //轨迹点
            var temppoints = [BMKMapPoint]()
            for _ in 0..<planPointCounts{
                temppoints.append(BMKMapPoint())
            }
            var i = 0
            for j in 0..<size {
                let transitStep = plan.steps[j] as! BMKDrivingStep
                for k in 0..<transitStep.pointsCount {
                    temppoints[i].x = transitStep.points[Int(k)].x
                    temppoints[i].y = transitStep.points[Int(k)].y
                    i += 1
                }
            }
            // 通过points构建BMKPolyline
            let polyLine = BMKPolyline.init(points: &temppoints, count: UInt(planPointCounts))
            mapView?.addOverlay(polyLine)
            //调用绘制路线的方法
            self.mapViewFitPolyLine(polyLine)
            
            mapView?.userTrackingMode = BMKUserTrackingModeHeading
            mapView?.showAnnotations(mapView?.annotations, animated: true)
            self.messageController.addLastMessage("路线加载成功...")
            
            //设置位置信息
            self.startLabel.text = "我的位置"
                //self.startPoint?.addressDetail.streetName
            self.endLabel.text = self.annotationTitle
            //开始规划路线时，底部视图出现
            self.bottomView.frame = CGRectMake(0, Utils.screenHeight - Utils.scaleFloat(100), Utils.screenWidth, Utils.scaleFloat(100))
            self.mapView?.frame = CGRectMake(0, 108, self.view.bounds.width, self.view.bounds.height - 108 - Utils.scaleFloat(100))
            //计算两点之间的距离
            let startPoint = BMKMapPointForCoordinate(self.userCurrentLocation.location.coordinate)
            let endPoint = BMKMapPointForCoordinate(self.endPoint!.location)
            var distance = BMKMetersBetweenMapPoints(startPoint,endPoint)
            self.currentDistance = distance
            //如果当前距离小于提示距离，则提示位置太近，不给予提示
            if distance < Double(self.promptDistance) {
                //关闭提示
                self.isOpenUp = false
                self.alertMessage("提示", message: "当前位置与目的地的距离小于提示距离",showOnVC: self, complete: nil)
                self.promptLabel.text = "未开启提示"
            }else{
                //开启提示
                self.isOpenUp = true
                self.isSendLocalNotification = false
                if self.promptDistance >= 1000  {
                    self.promptLabel.text = String.init(format: "当距离小于%.0lf千米时，将会开启提示", Double(self.promptDistance)/1000.0)
                }else{
                    self.promptLabel.text = "当距离小于\(self.promptDistance)米时，将会开启提示"
                }
            }
            
            if distance > 1000 {
                distance = distance / 1000.0
                self.currentDistanceLabel.text = String.init(format: "当前直线距离：%.1f千米", distance)
            }else{
                self.currentDistanceLabel.text = String.init(format: "当前直线距离：%.0lf米",distance)
            }
            //开启计算模式
            self.isStartDistanceCalculate = true
            //路线规划完毕，重新规划路线按钮恢复
            self.resetButton.enabled = true
        }
    }
    
    //MARK:绘制路线
    func mapViewFitPolyLine(polyLine: BMKPolyline){
        var ltX:Double = 0
        var ltY:Double = 0
        var rbX:Double = 0
        var rbY:Double = 0
        if polyLine.pointCount < 1 {
            return
        }
        let pt = polyLine.points[0]
        ltX = pt.x
        ltY = pt.y
        rbX = pt.x
        rbY = pt.y
        for i in 0..<Int(polyLine.pointCount) {
            let pt = polyLine.points[i]
            if pt.x < ltX {
                ltX = pt.x
            }
            if (pt.x) > rbX {
                rbX = (pt.x)
            }
            if (pt.y) > ltY {
                ltY = (pt.y)
            }
            if (pt.y) < rbY {
                rbY = (pt.y)
            }
        }
        var rect = BMKMapRect()
        rect.origin = BMKMapPointMake(ltX , ltY)
        rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY)
        self.mapView?.setVisibleMapRect(rect, animated: true)
        mapView?.zoomLevel = mapView!.zoomLevel - 0.3
    }
    
    
    //MARK:搜索控制器的代理方法，取消键盘
    func cancelEditing() {
        self.searchBar.resignFirstResponder()
        let subviews = self.searchBar.subviews.last?.subviews
        
        for view in subviews! {
            if view is UIButton {
                let cancel = view as! UIButton
                cancel.enabled = true
            }
        }
    }
    
    //MARk - 用户定位信息代理方法
    //MARK:在地图View将要启动定位时，会调用此函数
    func willStartLocatingUser() {
//        print("即将开始定位")
    }
    
    //MARK:用户方向更新后，会调用此函数
    func didUpdateUserHeading(userLocation: BMKUserLocation!) {
        // 说明:由于开启了“无限后台”的模式，所以可以直接写操作代码，然后系统默认在任何情况执行
        if UIApplication.sharedApplication().applicationState == .Active {// 1、活跃状态
            self.updateUserLocation(userLocation)
        }else if UIApplication.sharedApplication().applicationState == .Background{// 2、后台状态
            self.updateUserLocation(userLocation)
        }else if UIApplication.sharedApplication().applicationState == .Inactive{//不活跃状态
            self.updateUserLocation(userLocation)
        }
    }
    
    //MARK:更新用户位置信息
    func updateUserLocation(userLocation: BMKUserLocation!){
        //更新用户位置信息
        self.userCurrentLocation = userLocation
        mapView?.updateLocationData(userLocation)
        if self.isStartDistanceCalculate {//如果开启了位置计算功能，则实时计算位置
            //计算两点之间的距离
            let startPoint = BMKMapPointForCoordinate(self.userCurrentLocation.location.coordinate)
            let endPoint = BMKMapPointForCoordinate(self.endPoint!.location)
            var distance = BMKMetersBetweenMapPoints(startPoint,endPoint)
            self.currentDistance = distance
            if distance > 1000 {
                distance = distance / 1000.0
                self.currentDistanceLabel.text = String.init(format: "当前直线距离：%.1f千米", distance)
            }else{
                self.currentDistanceLabel.text = String.init(format: "当前直线距离：%.0lf米",distance)
            }
            //判断是否开启提示 ，是否进入提示范围内
            if isOpenUp && BMKMetersBetweenMapPoints(startPoint,endPoint) <= Double(self.promptDistance){
                //开始提示
                if UIApplication.sharedApplication().applicationState == .Background && !self.isSendLocalNotification{
                    //已经发送过本地通知，不会再次发送
                    self.isSendLocalNotification = true
//                    如果程序处于后台，则开启本地推送，并播放声音
                    self.registerLocalNotification()
                    
                    SystemMusic.shareInstance.playMusic(AVUser.currentUser()?.objectForKey("destinationPromptMusic") as! String, times: -1)
                }else if UIApplication.sharedApplication().applicationState == .Active && !self.isSendLocalNotification{
                    //已经发送过本地提示，不会再次发送
                    self.isSendLocalNotification = true
                    //如果程序处于前台，则开启提示框，并提示声音
                    SystemMusic.shareInstance.playMusic(AVUser.currentUser()?.objectForKey("destinationPromptMusic") as! String, times: -1)
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    self.alertMessage("提示", message: "已到达指定目的地\(self.getDistance(self.promptDistance))附近", showOnVC: self, complete: {
                        SystemMusic.shareInstance.stopMusic()
                    })
                }
            }
            
        }
    }
    
    //MARK:用户位置更新后，会调用此函数
    func didUpdateBMKUserLocation(userLocation: BMKUserLocation!) {
        if UIApplication.sharedApplication().applicationState == .Active {// 1、活跃状态
            self.updateUserLocation(userLocation)
        }else if UIApplication.sharedApplication().applicationState == .Background{// 2、后台状态
            self.updateUserLocation(userLocation)
        }else if UIApplication.sharedApplication().applicationState == .Inactive{//非活跃状态
            self.updateUserLocation(userLocation)
        }
    }
    
    //MARK:定位失败后，会调用此函数
    func didFailToLocateUserWithError(error: NSError!) {
        Utils.showMessageOnView(self.view, message: "定位失败", time: 2, block: nil)
    }
    
    //MARK:消息提示
    func alertMessage(title: String,message: String,showOnVC: UIViewController, complete: completeClosure?){
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .Alert)
        let confirm = UIAlertAction.init(title: "好", style: .Destructive) { (action) in
            if complete != nil{
                complete!()
            }
        }
        alert.addAction(confirm)
        showOnVC.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK:开启本地推送
    func registerLocalNotification(){
        let notification = UILocalNotification()
        //设置开启时间  3秒钟之后
        notification.fireDate = NSDate.init(timeIntervalSinceNow: 3)
        //设置时区
        notification.timeZone = NSTimeZone.defaultTimeZone()
        //设置重复间隔
        notification.repeatInterval = NSCalendarUnit.Second
        //设置通知内容
        notification.alertBody = "已到达指定目的地\(self.getDistance(self.promptDistance))附近"
        notification.applicationIconBadgeNumber = 1
        //通知被触发时的声音
        notification.soundName = "\(AVUser.currentUser()?.objectForKey("destinationPromptMusic")).m4r"
        //UILocalNotificationDefaultSoundName
        //设置userDic
        notification.userInfo = ["Arrived":"已到达指定目的地\(self.getDistance(self.promptDistance))附近"]
        //iOS 8 之后需要注册才能得到授权
        if UIApplication.sharedApplication().respondsToSelector(#selector(UIApplication.sharedApplication().registerUserNotificationSettings(_:))) {
            let settings = UIUserNotificationSettings.init(forTypes: [UIUserNotificationType.Alert,UIUserNotificationType.Badge,UIUserNotificationType.Sound], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            notification.repeatInterval = NSCalendarUnit.Second
        }else{
            notification.repeatInterval = NSCalendarUnit.Second
        }
        
        //执行通知的注册
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    //MARK:获取当前距离
    func getDistance(distance: Int) -> String{
        if distance >= 1000 {
            return String.init(format: "%0.1lf千米", Double(distance)/1000.0)
        }else{
            return String.init(format: "%d米", distance)
        }
    }
    
    deinit{
        mapView?.delegate = nil // 不用时，置nil
        locService.delegate = nil
        mapSearch.delegate = nil
        geocodesearch.delegate = nil
        routeSearch.delegate = nil
        print("目的地界面释放")
    }
    
}
