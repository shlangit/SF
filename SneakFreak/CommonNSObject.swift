//
//  CommonNSObject.swift
//  GymGuide
//
//  Created by Reid on 2/18/16.
//  Copyright © 2016 Hitesh Dholakiya. All rights reserved.
//

import UIKit

class CommonNSObject: NSObject {
    
    
    class func removeWhiteSpace (str : String) -> String
    {
        
    var refineStr : String
        
    refineStr = str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    refineStr = refineStr.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        return refineStr
    }
    
    class func onLikePost(var likeUsers : String , userObjectId : String) -> NSString
    {
        
        if (likeUsers as NSString).length == 0
        {
            likeUsers = userObjectId
        }
        else
        {
            likeUsers = likeUsers + "," + userObjectId
        }
        
        return likeUsers
        
    }
    
    class func onDisLikePost(var likeUsers : String , userObjectId : String) -> NSString
    {
        
        likeUsers = likeUsers.stringByReplacingOccurrencesOfString("," + userObjectId , withString: "")
        
        likeUsers = likeUsers.stringByReplacingOccurrencesOfString(userObjectId + "," , withString: "")
        
        likeUsers = likeUsers.stringByReplacingOccurrencesOfString(userObjectId , withString: "")
        
        return likeUsers
        
    }

}

