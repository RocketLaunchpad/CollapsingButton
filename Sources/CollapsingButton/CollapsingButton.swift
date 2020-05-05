//
//  CollapsingButton.swift
//  CollapsingButton
//
//  Copyright (c) 2020 Rocket Insights, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import UIKit

/// A collapsing button. A container view is passed to the initializer. The button is automatically added to the bottom of that container view. When `isCollapsed` is set to `false` (the default), the button spans the width of the bottom of the container view. When `isCollapsed` is set to `true`, the button shrinks to be a circle in the lower-right corner of the container view.
///
/// Setting this button as a delegate of a `UIScrollView` will cause it to automatically expand or collapse based on the scrolling behavior. This will automatically collapse when scrolling down (swiping up) and expand when scrolling up (swiping down).
///
/// You cannot set a `UIScrollViewDelegate` on a `UITableViewController`. In order to use a `CollapsingButton` with a `UITableViewController`, you will need to implement the following delegate methods and forward them to the `CollapsingButton` instance. For example:
///
/// ```
/// private var collapsingButton: CollapsingButton!
///
/// override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
///     collapsingButton.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
/// }
///
/// override func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
///     collapsingButton.scrollViewDidScrollToTop(scrollView)
/// }
/// ```
public class CollapsingButton: UIControl {

    // MARK: - Subviews

    /// The image view that will always be visible in the button.
    public let imageView: UIImageView

    /// The label that will only be visible when the button is expanded.
    public let label: UILabel

    // MARK: - Constants

    /// Margin between contents and self.view.
    private let margin: UIEdgeInsets = .init(top: 12, left: 8, bottom: -12, right: -8)

    /// Padding between button and container UIScrollView's safe area. Top inset is ignored.
    private let padding: UIEdgeInsets = .init(top: 0, left: 20, bottom: -20, right: -20)

    /// Duration of the collapse/expand animation
    private let animationDuration: TimeInterval = 0.25

    /// Corner radius when in expanded mode. When in collapsed mode, corner radius is equal to half the height.
    private let expandedCornerRadius: CGFloat = 5

    /// Spacing between the image view and the label.
    private let imageViewToLabelSpacing: CGFloat = 8

    // Shadow configuration
    private let shadowRadius: CGFloat = 5
    private let shadowColor: UIColor = .black
    private let shadowOpacity: Float = 0.33
    private let shadowOffset: CGSize = .zero

    // MARK: - Initialization

    /// Creates a new collapsing button and adds it to the bottom of the specified view. The new button will collapse to the bottom right of the specified view.
    public init(addedTo view: UIView) {
        imageView = UIImageView(frame: .zero)
        imageView.isUserInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        label = UILabel(frame: .zero)
        label.isUserInteractionEnabled = false
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false

        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        addAndConstrainChildViews()
        addToBottom(of: view)

        layer.cornerRadius = expandedCornerRadius
        layer.shadowRadius = shadowRadius
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = shadowOffset

        // Clip to bounds as the label will animate out of the bounds as it fades out.
        // clipsToBounds = true
    }

    public required init?(coder: NSCoder) {
        fatalError("initt(coder:) has not been implemented")
    }

    /// Creates the centering view and adds it as a subview. Builds constraints between the centering view and our view, as well as between the image view and our view.
    private func addAndConstrainChildViews() {
        let centeringView = buildCenteringView()
        addSubview(centeringView)

        // Pin top and bottom of centering view
        centeringView.topAnchor.constraint(equalTo: topAnchor, constant: margin.top).isActive = true
        centeringView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: margin.bottom).isActive = true

        // Pin left and right, plus horizontally center the centering view when expanded
        let expanded = [
            centeringView.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: margin.left),
            centeringView.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: margin.right),
            centeringView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ]
        NSLayoutConstraint.activate(expanded)
        expandedConstraints.append(contentsOf: expanded)

        // Horizontally center the image view when collapsed
        let collapsed = [
            centeringView.rightAnchor.constraint(equalTo: rightAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
        ]
        NSLayoutConstraint.deactivate(collapsed)
        collapsedConstraints.append(contentsOf: collapsed)
    }

    /// Adds the image view and label to a centering view. This is used to center that content in our view when expanded. Builds constraints internal to the centering view.
    private func buildCenteringView() -> UIView {
        let centeringView = UIView(frame: .zero)

        // We can't set clipsToBounds on the superview because that will hide the shadow. Set it on the centering view so when we resize, the text won't flow out of the superview.
        centeringView.clipsToBounds = true
        centeringView.translatesAutoresizingMaskIntoConstraints = false
        centeringView.isUserInteractionEnabled = false
        centeringView.addSubview(imageView)
        centeringView.addSubview(label)

        // Image view aspect ratio
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1).isActive = true

        // Image view pinned top, left, and bottom to centering view
        imageView.topAnchor.constraint(greaterThanOrEqualTo: centeringView.topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: centeringView.leftAnchor).isActive = true
        imageView.bottomAnchor.constraint(greaterThanOrEqualTo: centeringView.bottomAnchor).isActive = true

        // Label pinned top, right, and bottom to centering view
        label.topAnchor.constraint(greaterThanOrEqualTo: centeringView.topAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: centeringView.rightAnchor).isActive = true
        label.bottomAnchor.constraint(greaterThanOrEqualTo: centeringView.bottomAnchor).isActive = true

        // Spacing between image view and label
        label.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: imageViewToLabelSpacing).isActive = true

        // Top and bottom anchors are ≥ so the taller of the two determine the height.
        // We need to make both centered vertically to eliminate ambiguity.
        imageView.centerYAnchor.constraint(equalTo: centeringView.centerYAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centeringView.centerYAnchor).isActive = true

        return centeringView
    }

    /// Adds to the bottom of the specified view. Constraints are added between self and the specified view.
    private func addToBottom(of view: UIView) {
        view.addSubview(self)

        // Constant constraints
        rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: padding.right).isActive = true
        bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: padding.bottom).isActive = true

        // Expanded-mode constraints, activated as we start expanded
        let expanded = [
            leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: padding.left)
        ]
        expandedConstraints.append(contentsOf: expanded)
        NSLayoutConstraint.activate(expanded)

        // Collapsed-mode constraints, deactivated as we start expanded
        let collapsed = [
            widthAnchor.constraint(equalTo: heightAnchor)
        ]
        collapsedConstraints.append(contentsOf: collapsed)
        NSLayoutConstraint.deactivate(collapsed)
    }

    // MARK: - Properties

    /// Constraints that are only activated when expanded.
    private var expandedConstraints: [NSLayoutConstraint] = []

    /// Constraints that are only activated when collapsed.
    private var collapsedConstraints: [NSLayoutConstraint] = []

    /// Collapses or expands the view.
    public var isCollapsed: Bool = false {
        didSet {
            if oldValue != isCollapsed {
                setCollapsed(isCollapsed)
            }
        }
    }

    /// Foreground color for subviews.
    public var foregroundColor: UIColor? {
        didSet {
            imageView.tintColor = foregroundColor
            label.textColor = foregroundColor
        }
    }

    // MARK: - Animation

    /// Do not call this directly. This is intended to be called by the `isCollapsed` property observer, which ensures that the state has changed before calling this.
    private func setCollapsed(_ collapsed: Bool) {
        // We need to layout the superview as we are changing out position and size.
        superview?.layoutIfNeeded()

        UIView.animate(withDuration: animationDuration, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
            // Change the corner radius
            self.layer.cornerRadius = collapsed ? self.frame.height / 2 : self.expandedCornerRadius

            // Deactivate constraints before we activate potentially conflicting ones
            NSLayoutConstraint.deactivate(collapsed ? self.expandedConstraints : self.collapsedConstraints)
            NSLayoutConstraint.activate(collapsed ? self.collapsedConstraints : self.expandedConstraints)

            // Fade in/out the label
            self.label.alpha = collapsed ? 0 : 1

            // We need to layout the superview as we are changing out position and size.
            self.superview?.layoutIfNeeded()
        }, completion: nil)
    }
}

extension CollapsingButton: UIScrollViewDelegate {

    /// Always expand when scrolling to top
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        isCollapsed = false
    }

    /// Use velocity to determine whether to collapse or expand. Collapse when scrolling down (swiping up) and expand when scrolling up (swiping down).
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.y < 0 {
            isCollapsed = false
        }
        else if velocity.y > 0 {
            isCollapsed = true
        }
    }
}
