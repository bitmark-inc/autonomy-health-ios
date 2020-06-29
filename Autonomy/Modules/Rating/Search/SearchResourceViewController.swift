//
//  SearchResourceViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/8/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import SwiftRichString

class SearchResourceViewController: SearchSurveyViewController {

    lazy var thisViewModel: SearchResourceViewModel = {
        return viewModel as! SearchResourceViewModel
    }()

    var filteredRecords = [Resource]()

    override func bindViewModel() {
        super.bindViewModel()

        _ = searchTextField.rx.textInput => thisViewModel.searchNameTextRelay

        thisViewModel.filteredRecordsResultRelay
            .subscribe(onNext: { [weak self] in
                self?.filteredRecords = $0
                self?.resultTableView.reloadData()
            })
            .disposed(by: disposeBag)

        thisViewModel.newResourceSubject
            .subscribe(onNext: { [weak self] (_) in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }

    override func setupViews() {
        super.setupViews()

        searchTextField.delegate = self
        resultTableView.dataSource = self
        resultTableView.delegate = self
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate
extension SearchResourceViewController: UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRecords.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: SearchSurveyTableCell.self)

        let autoCompleteName = filteredRecords[indexPath.row].name
        let searchText = thisViewModel.searchNameTextRelay.value

        cell.setData(attributedText: makeAttributedText(searchText, in: autoCompleteName))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let record = filteredRecords[indexPath.row]
        thisViewModel.newResourceSubject.onNext(record)
        dismiss(animated: true, completion: nil)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, text.isNotEmpty else {
            dismiss(animated: true, completion: nil)
            return true
        }

        let localResource = thisViewModel.extractResource(name: text)
        thisViewModel.newResourceSubject.onNext(localResource)
        return false
    }
}
