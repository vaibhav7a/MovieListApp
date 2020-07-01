//
//  File.swift
//  
//
//  Created by Vaibhav Jain on 05/01/20.
//

import Foundation

public struct CommunityServiceManager {
    static  let HSRouter = Router<CommunityServiceApi>()

    static func getArticles(param  : [String : Any], isFirstRequest : Bool, completion: @escaping ([ParentTree]?, APIError?) -> Void) {
        HSRouter.fetchRequest(.getHomeData(params: param)) { responseJson,error  in
            if error == nil {
                guard let result = responseJson  else {
                    completion(nil,nil)
                    return
                }
                if isFirstRequest{
                    CoreDataManager.deleteAllParentRecords()
                    CoreDataManager.deleteAllMediaRecords()
                    CoreDataManager.deleteAllUserRecords()
                }
                let blogArray = [ParentTree]()
                for article in result {
                    CoreDataManager.addRecord(article: article)
                }
                completion(blogArray,nil)
                print(result)
            }
            else{
                completion(nil,error)
            }
        }

    }
}
