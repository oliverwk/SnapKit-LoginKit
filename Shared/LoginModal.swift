//
//  LoginCVWrapper.swift
//  snap
//
//  Created by Olivier Wittop Koning on 14/03/2021.
//

import SCSDKLoginKit
import Combine
import SwiftUI

struct LoginCVWrapper: UIViewControllerRepresentable {
    @Binding private var displayName: String
    @Binding private var done: Bool
    @Binding private var isPresented: Bool
    @Binding private var bitmojiAvatar: UIImage
    
    
    init(displayName: Binding<String>, isPresented: Binding<Bool>, bitmojiAvatar: Binding<UIImage>, done: Binding<Bool>) {
        _displayName = displayName
        _bitmojiAvatar = bitmojiAvatar
        _isPresented = isPresented
        _done = done
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let loginView = LoginViewController()
        loginView.delegate = context.coordinator
        return loginView
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        //not used
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    class Coordinator: NSObject, LoginViewControlDelegate {
        let parent: LoginCVWrapper
        
        init(_ parent: LoginCVWrapper) {
            self.parent = parent
        }
        
        func SnapUpdate(displayName: String, bitmojiAvatar: UIImage) {
            parent.bitmojiAvatar = bitmojiAvatar
            parent.displayName = displayName
            parent.$isPresented.wrappedValue.toggle()
            parent.$done.wrappedValue.toggle()
        }
    }
}

public protocol LoginViewControlDelegate : NSObjectProtocol {
    func SnapUpdate(displayName: String, bitmojiAvatar: UIImage)
}

class LoginViewController: UIViewController {
    
    weak open var delegate: LoginViewControlDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        performLogin() //Attempt Snap Login Here
    }
    
    //Snapchat Credential Retrieval Fails Here
    private func performLogin() {
        //SCSDKLoginClient.login() never completes once scene becomes active again after Snapchat redirect back to this app.
        
        SCSDKLoginClient.login(from: self, completion: { success, error in
            if let error = error {
                print("Error: while SCSDKLoginClient.login() \(error.localizedDescription)")
                return
            }
            print("Login was succesfull!")
            if success {
                let graphQLQuery = "{me{displayName, bitmoji{avatar}}}"
                print("Fetching User Data")
                SCSDKLoginClient.fetchUserData(withQuery: graphQLQuery, variables: nil, success: { (resources: [AnyHashable: Any]?) in
                    guard let resources = resources,
                          let data = resources["data"] as? [String: Any],
                          let me = data["me"] as? [String: Any] else { return }
                    let displayName = me["displayName"] as? String
                    print(displayName ?? "No Name")
                    var bitmojiAvatarUrl: String?
                    if let bitmoji = me["bitmoji"] as? [String: Any] {
                        bitmojiAvatarUrl = bitmoji["avatar"] as? String
                    }
                    DispatchQueue.main.async {
                        print("Fetching User Data was Sucessful: { \"displayName\" \"\(me["displayName"] ?? "No name")\", \"url\":  \"\(bitmojiAvatarUrl ?? "No bitmojiAvatarUrl" )\" }")
                        if let data = try? Data(contentsOf: URL(string: bitmojiAvatarUrl!)!) {
                            if let image = UIImage(data: data) {
                                self.delegate?.SnapUpdate(displayName: me["displayName"] as? String ?? "No Name", bitmojiAvatar: image)
                            }
                        }
                    }
                }, failure: { (error: Error?, isUserLoggedOut: Bool) in
                    // handle error
                    print("Error", error as Any)
                })
            }
        })
    }
}

/*
Old-Code
not used
 func AddUI() -> Void {
     let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 50.0))
     label.text = me["displayName"] as? String ?? "No Name"
     label.center = self.view.center
     label.font = UIFont(name:"SF UI Display Bold", size: 20.0)
     self.view.addSubview(label)
     
     let heightInPoints = image.size.height
     let heightInPixels = heightInPoints * image.scale
     label.center = CGPoint(x: (self.view.center.x + 50), y: (self.view.center.y + heightInPixels))
     let imgView = UIImageView(image: image)
     imgView.center = self.view.center
     self.view.addSubview(imgView)
 }
 */
