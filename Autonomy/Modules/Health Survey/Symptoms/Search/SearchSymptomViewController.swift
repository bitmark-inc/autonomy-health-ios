//
//  SearchSymptomViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/11/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import SwiftRichString

class SearchSymptomViewController: SearchSurveyViewController {

    lazy var thisViewModel: SearchSymptomViewModel = {
        return viewModel as! SearchSymptomViewModel
    }()

    var filteredRecords = [Symptom]()

    override func bindViewModel() {
        super.bindViewModel()

        _ = searchTextField.rx.textInput => thisViewModel.searchNameTextRelay

        thisViewModel.filteredRecordsResultRelay
            .subscribe(onNext: { [weak self] in
                self?.filteredRecords = $0
                self?.resultTableView.reloadData()
            })
            .disposed(by: disposeBag)

        thisViewModel.submitSymptomResultSubject
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (event) in
                guard let self = self else { return }
                loadingState.onNext(.hide)
                switch event {
                case .error(let error):
                    self.errorWhenSubmit(error: error)
                case .next(let symptom):
                    Global.log.info("[done] added new symptom")
                    self.thisViewModel.newSymptomSubject.onNext(symptom)
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
extension SearchSymptomViewController: UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
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
        let behavior = filteredRecords[indexPath.row]
        thisViewModel.newSymptomSubject.onNext(behavior)
        dismiss(animated: true, completion: nil)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, text.isNotEmpty else {
            return true
        }

        thisViewModel.submitSymptom(name: text)
        return false
    }
}
