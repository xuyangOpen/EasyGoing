//
//  DBManager.swift
//  EasyGoing
//
//  Created by King on 16/11/10.
//  Copyright © 2016年 kf. All rights reserved.
//
import FMDB

class DBManager: NSObject {

    //单例模式的数据库管理类
    static let sharedInstance = DBManager()
    private override init() {}
    
    let db = FMDatabase.init(path: "/tmp/easygoing.db")
    
    //MARK:配置数据库
    func configDB(){
        if db.open() {
            if !db.tableExists("eg_user"){//判断用户表是否存在
                let sql = "create table eg_user (user_onlykey text primary key)"
                if db.executeStatements(sql) {
                    print("创建用户表成功")
                }else{
                    print("创建用户表失败")
                }
            }
            db.close()
        }
    }
    
    //MARK:保存用户登录口令
    func saveUserOnlyKey(key:String) -> Bool{
        if db.open() {
            if db.tableExists("eg_user") {
                let sql = "insert into eg_user (user_onlykey) values ('" + key + "')"
                if db.executeStatements(sql) {
                    print("已成功保存用户新的登录口令")
                    return true
                }else{
                    print("保存用户登录口令失败")
                }
            }
            db.close()
        }
        return false
    }
    
    //MARK:查询用户登录口令
    func queryUserOnlyKey() -> String?{
        if db.open() {
            if db.tableExists("eg_user") {
                if let rs = db.executeQuery("select user_onlykey from eg_user", withArgumentsInArray: nil){
                    while rs.next() {
                        let onlyKey = rs.stringForColumn("user_onlykey")
                        return onlyKey
                    }
                }
            }
            db.close()
        }
        return nil
    }
    
    //MARK:清除用户登录口令
    func cleanUserOnlyKey() -> Bool{
        if db.open() {
            if db.tableExists("eg_user") {
                let sql = "delete from eg_user"
                if db.executeStatements(sql) {
                    print("已清除登录口令")
                    return true
                }else{
                    print("删除数据失败")
                }
            }
            db.close()
        }
        return false
    }
    
}
