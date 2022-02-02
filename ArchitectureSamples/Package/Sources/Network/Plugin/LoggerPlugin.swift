//
//  LoggerPlugin.swift
//
//  Created by kntk on 2021/10/24.
//

import Moya

struct LoggerPlugin: PluginType {

    func willSend(_ request: RequestType, target: TargetType) {
        request.request.map { Logger.debug("Target: \(target)\n\($0.curlString)") }
    }

    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let response):
            Logger.debug("Success\nTarget: \(target)\nResponse: \(response)")

        case .failure(let error):
            Logger.debug("Failure\nTarget: \(target)\nError: \(error)")
        }
    }
}
