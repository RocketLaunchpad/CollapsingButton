//
//  TableViewController.swift
//  CollapsingButtonExample
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

import CollapsingButton
import UIKit

class TableViewController: UITableViewController {

    private var formatter: NumberFormatter!

    private var collapsingButton: CollapsingButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        formatter = NumberFormatter()
        formatter.numberStyle = .spellOut

        collapsingButton = CollapsingButton(addedTo: tableView)
        collapsingButton.backgroundColor = .orange
        collapsingButton.foregroundColor = .white
        collapsingButton.label.text = "Collapsing Button"
        collapsingButton.imageView.image = UIImage(systemName: "square.and.arrow.up")
        collapsingButton.addTarget(self, action: #selector(toggleCollapsingButton(_:)), for: .touchUpInside)
    }

    @objc private func toggleCollapsingButton(_ sender: CollapsingButton) {
        sender.isCollapsed = !sender.isCollapsed
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 250
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ?? UITableViewCell(style: .default, reuseIdentifier: id)

        cell.textLabel?.text = formatter.string(from: NSNumber(value: indexPath.row + 1))
        return cell
    }

    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        collapsingButton.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }

    override func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        collapsingButton.scrollViewDidScrollToTop(scrollView)
    }
}
