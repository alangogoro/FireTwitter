//
//  TweetViewModel.swift
//  FireTwT
//
//  Created by usr on 2021/1/27.
//
import Foundation
import UIKit

struct TweetViewModel {
    
    let tweet: Tweet
    let user: User
    
    var profileImageUrl: URL? {
        return user.profileImageUrl
    }
    
    var usernameText: String {
        return "@" + user.username
    }
    
    var userInfoText: NSAttributedString {
        let title = NSMutableAttributedString(string: user.fullname,
                                              attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        
        let subTitle = NSAttributedString(string: " @\(user.username)",
                                          attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                       .foregroundColor: UIColor.lightGray])
        // ➡️ 因為是 NSMutable 字串所以可以 append
        title.append(subTitle)
        
        let stamp = NSAttributedString(string: "．\(timestamp)",
                                       attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                    .foregroundColor: UIColor.lightGray])
        // ➡️ 因為是 NSMutable 字串所以可以 append
        title.append(stamp)
        
        return title
    }
    
    var likeButtonTintColor: UIColor {
        return tweet.didLike ? .red : .lightGray
    }
    
    var likeButtonImage: UIImage {
        let imageName = tweet.didLike ? "like_filled" : "like"
        return UIImage(named: imageName)!
    }
    
    /// Tweet 的發文時間距今有多久
    var timestamp: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated // 精簡表示時間單位
        
        let now = Date()
        return formatter.string(from: tweet.timestamp, to: now) ?? "0m"
    }
    
    var headerTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a・MM/dd/yyyy"
        return formatter.string(from: tweet.timestamp)
    }
    
    var retweetAttributedString: NSAttributedString? {
        return attributedString(withValue: tweet.retweetCount, text: "Retweets")
    }
    var likesAttributedString: NSAttributedString? {
        return attributedString(withValue: tweet.likes, text: "Likes")
    }
    
    init(tweet: Tweet) {
        self.tweet = tweet
        self.user = tweet.user
    }
    
    fileprivate func attributedString(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle =
            NSMutableAttributedString(string: "\(value)",
                                      attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedTitle
            .append(NSAttributedString(string: " \(text)",
                                       attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                    .foregroundColor: UIColor.lightGray]))
        return attributedTitle
    }
    
    /// 傳入螢幕寬度以計算出每條 Tweet Cell 所需要的尺寸
    func measuredSize(forWidth width: CGFloat) -> CGSize {
        let measureLabel = UILabel()
        measureLabel.text = tweet.caption
        measureLabel.numberOfLines = 0
        measureLabel.lineBreakMode = .byWordWrapping // 斷行單位
        
        // ⭐️ AutoLayout 設定寬度 ⭐️
        measureLabel.translatesAutoresizingMaskIntoConstraints = false
        measureLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
        
        // ❗️回傳 View 元件在遵守了寬度約束之下最緊湊適配的 Size❗️
        return measureLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}
