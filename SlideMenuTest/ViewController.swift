//
//  ViewController.swift
//  SlideMenuTest
//
//  Created by Omar Ali on 6/23/18.
//  Copyright © 2018 Omar Ali. All rights reserved.
//

import UIKit



class CustomCell: UITableViewCell {
    
    init(string: String) {
        
        super.init(style: .default, reuseIdentifier: "cell")
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = string
        addSubview(label)
        label.topAnchor.constraint(equalTo: topAnchor, constant: 20.0)
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 20.0)
        label.centerXAnchor.constraint(equalTo: centerXAnchor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ViewController: UIViewController,  SlidupButtonDelegate {

    let button: SlideupButton = {
        let button = SlideupButton(items: ["Delete", "Report", "Block User", "Cancel"])
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Open Menu", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.viewBackgroundColor = .blue
        return button
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.addSubview(button)
        button.delegate = self
        button.view = self.view
        
        button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
    }

    func didSelectItem(for button: SlideupButton, selectedItem: String, selectedItemIndex: Int) {
        print("\(selectedItem) -> \(selectedItemIndex)")
    }
    
}


protocol SlidupButtonDelegate {
    func didSelectItem(for button: SlideupButton, selectedItem: String, selectedItemIndex: Int)
}

class SlideupButton: UIButton, SlideupMenuTableViewDelegate {
    
    
    let slideupMenuTableView: SlideupMenuTableView
    var heightConstraint: NSLayoutConstraint?
    var viewBackgroundColor: UIColor = .white {
        didSet {
            slideupMenuTableView.backgroundColor = self.viewBackgroundColor
            slideupMenuTableView.backgroundView?.backgroundColor = self.viewBackgroundColor
        }
    }
    
    var animationDuration = 0.25
    
    weak var view: UIView? {
        didSet {
            
            if view != nil {
                view!.addSubview(self.slideupMenuTableView)
                slideupMenuTableView.bottomAnchor.constraint(equalTo: view!.bottomAnchor).isActive = true
                slideupMenuTableView.leftAnchor.constraint(equalTo: view!.leftAnchor).isActive = true
                slideupMenuTableView.rightAnchor.constraint(equalTo: view!.rightAnchor).isActive = true
                self.heightConstraint = slideupMenuTableView.heightAnchor.constraint(equalToConstant: CGFloat(0))
                self.heightConstraint?.isActive = true
                print("")
            }
  
        }
    }
    var maximumHeight: Float = 300
    var delegate: SlidupButtonDelegate?
    
    init(items: [String]) {
        slideupMenuTableView = SlideupMenuTableView(items: items)
        
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        slideupMenuTableView.slideupMenuDelegate = self
        slideupMenuTableView.translatesAutoresizingMaskIntoConstraints = false
        self.addTarget(self, action: #selector(didTapOnButton), for: .touchUpInside)
        
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var menuIsOpened = false
    
    @objc private func didTapOnButton() {
       
        if self.view == nil {
            fatalError("You must provide a container view for the menu. Do this by setting the view property of your button.")
        }
        
        let height: CGFloat = slideupMenuTableView.contentSize.height
        

        
        
        if menuIsOpened {
            dismissSlideView()
        }
        else {
            showSlideView(height)
        }
        
        
    }
    
    private func dismissSlideView() {
        
        heightConstraint?.constant = 0
        
        performShowingOrHidingWithAnimation(openingMenu: false)
        
        menuIsOpened = false
    }
    
    private func showSlideView(_ height: CGFloat) {
        heightConstraint?.constant = height
        
        performShowingOrHidingWithAnimation(openingMenu: true)
        
        menuIsOpened = true
    }
    
    private func performShowingOrHidingWithAnimation(openingMenu: Bool) {
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseIn, animations: {
            self.slideupMenuTableView.layoutIfNeeded()
            
            if openingMenu {
                self.slideupMenuTableView.center.y -= self.slideupMenuTableView.frame.height / 2
            }
            else {
                self.slideupMenuTableView.center.y += self.slideupMenuTableView.frame.height / 2
            }
            
        }, completion: nil)
        
    }
    
    func didSelectItem(selectedItem: String, selectedItemIndex: Int) {
        delegate?.didSelectItem(for: self, selectedItem: selectedItem, selectedItemIndex: selectedItemIndex)
        dismissSlideView()
        
    }
    
}

protocol SlideupMenuTableViewDelegate {
    func didSelectItem(selectedItem: String, selectedItemIndex: Int)
}

protocol SlideupMenuTableViewDataSource {
    func numberOfItems(in slideupMenu: SlideupMenuTableView) -> Int
    func slideupMenu(_ slideupMenu: SlideupMenuTableView, cellForItemAt row: Int) -> UITableViewCell
}


class SlideupMenuTableView: UITableView, UITableViewDelegate, UITableViewDataSource {

    private let menuItems: [String]
    var slideupMenuDelegate: SlideupMenuTableViewDelegate?
    var slideUpMenuDataSource: SlideupMenuTableViewDataSource?
    
    init(items: [String]) {
        self.menuItems = items
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .plain)
        self.dataSource = self
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return slideUpMenuDataSource?.numberOfItems(in: self) ?? menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let slideUpMenuDataSource = slideUpMenuDataSource {
            return slideUpMenuDataSource.slideupMenu(self, cellForItemAt: indexPath.row)
        }
        
        let cell = UITableViewCell()
        cell.textLabel?.text = menuItems[indexPath.row]
        cell.backgroundColor = self.backgroundColor
        cell.backgroundColor = .blue
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        slideupMenuDelegate?.didSelectItem(selectedItem: menuItems[indexPath.row], selectedItemIndex: indexPath.row)
    }
    
    
    
}

