//
//  NetworkServerManager.swift
//  PerfectTemplatePackageDescription
//
//  Created by lx on 2018/1/3.
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

open class NetworkServerManager {

    fileprivate var server: HTTPServer
    internal init(root: String, port: UInt16) {

        server = HTTPServer.init()                          //创建HTTPServer服务器
        var routes = Routes.init(baseUri: "/api")           //创建路由器
        configure(routes: &routes)                          //注册路由
        server.addRoutes(routes)                            //路由添加进服务
        server.serverPort = port                            //端口
        server.documentRoot = root                          //根目录
        server.setResponseFilters([(Filter404(), .high)])   //404过滤

    }

    //MARK: 开启服务
    open func startServer() {

        do {
            print("启动HTTP服务器成功")
            try server.start()
        } catch PerfectError.networkError(let err, let msg) {
            print("启动HTTP服务器失败：\(err) \(msg)")
        } catch {
            print("启动HTTP服务器失败：\(error)")
        }

    }

    //MARK: 注册路由
    fileprivate func configure(routes: inout Routes) {

        // 添加接口,请求方式,路径
        routes.add(method: .get, uri: "/") { (request, response) in
            response.setHeader( .contentType, value: "text/json")          //响应头
            let jsonDic = ["hello": "world"]
            let jsonString = self.baseResponseBodyJSONData(status: 200, message: "成功", data: jsonDic)
            response.setBody(string: jsonString)                           //响应体
            response.completed()                                           //响应
        }

    }

    //MARK: 通用响应格式
    func baseResponseBodyJSONData(status: Int, message: String, data: Any!) -> String {

        var result = Dictionary<String, Any>()
        result.updateValue(status, forKey: "status")
        result.updateValue(message, forKey: "message")
        if (data != nil) {
            result.updateValue(data, forKey: "data")
        }else{
            result.updateValue("", forKey: "data")
        }
        guard let jsonString = try? result.jsonEncodedString() else {
            return ""
        }
        return jsonString

    }

    //MARK: 404过滤
    struct Filter404: HTTPResponseFilter {

        func filterBody(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
            callback(.continue)
        }

        func filterHeaders(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
            if case .notFound = response.status {
                response.setHeader(.contentType, value: "text/html")
                response.appendBody(string: "<html><title>404</title><body>404 not found</body></html>")
                callback(.done)
            } else {
                callback(.continue)
            }
        }

    }

}

