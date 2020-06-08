//
//  SearchResourceVieController.swift
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

class SearchResourceVieController: SearchSurveyViewController {

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

        thisViewModel.submitResourceResultSubject
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (event) in
                guard let self = self else { return }
                loadingState.onNext(.hide)
                switch event {
                case .error(let error):
                    self.errorWhenSubmit(error: error)
                case .next(let resource):
                    Global.log.info("[done] added new resource")
                    self.thisViewModel.newResourceSubject.onNext(resource)
                    self.dismiss(animated: true, completion: nil)
                default:
                    break
                }
            }).disposed(by: disposeBag)
    }

    override func setupViews() {
        super.setupViews()

        searchTextField.delegate = self
        resultTableView.dataSource = self
        resultTableView.delegate = self
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate
extension SearchResourceVieController: UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRecords.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: SearchSurveyTableCell.self)

        let autoCompleteName = filteredRecords[indexPath.row].name.lowercased()
        let searchText = thisViewModel.searchNameTextRelay.value.lowercased()

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

        thisViewModel.submitResouce(name: text)
        return false
    }
}
