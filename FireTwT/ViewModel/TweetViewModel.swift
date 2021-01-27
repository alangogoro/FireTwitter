//
//  TweetViewModel.swift
//  FireTwT
//
//  Created by usr on 2021/1/27.
//
import Foundation

struct TweetViewModel {
    
    let tweet: Tweet
    
    var profileImageUrl: URL? {
        return tweet.user.profileImageUrl
    }
    
    init(tweet: Tweet) {
        self.tweet = tweet
    }
    
}
