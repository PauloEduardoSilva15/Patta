//
//  SearchViewModel.swift
//  Patta
//
//  Created by Pedro Canute on 25/08/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class SearchViewModel {
    var query = ""

    private let petStore: PetListStore
    private let taskStore: TaskListStore

    init(petStore: PetListStore, taskStore: TaskListStore) {
        self.petStore = petStore
        self.taskStore = taskStore
    }

    var treatedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isQueryEmpty: Bool {
        treatedQuery.isEmpty
    }

    var filteredPets: [PetModel] {
        let searchText = normalized(treatedQuery)

        guard !searchText.isEmpty else {
            return []
        }

        return petStore.pets
            .filter { pet in
                normalized(pet.name)
                    .contains(searchText)
            }
            .sorted { first, second in
                comesBefore(firstTitle: first.name,firstID: first.id,secondTitle: second.name,secondID: second.id,searchText: searchText)
            }
    }

    var filteredTasks: [TaskModel] {
        let searchText = normalized(treatedQuery)

        guard !searchText.isEmpty else {
            return []
        }

        return taskStore.tasks
            .filter { task in
                let titleMatches =
                    normalized(task.title).contains(searchText)

                let petName = task.pet?.name ?? ""

                let petMatches = normalized(petName).contains(searchText)

                return titleMatches || petMatches
            }
            .sorted { first, second in
                comesBefore(firstTitle: first.title, firstID: first.id, secondTitle: second.title, secondID: second.id, searchText: searchText)
            }
    }

    var hasNoResults: Bool {
        !isQueryEmpty && filteredPets.isEmpty && filteredTasks.isEmpty
    }

    private func normalized(_ text: String) -> String {
        text.folding(options: [ .caseInsensitive,.diacriticInsensitive], locale: .current)
    }

    private func comesBefore(firstTitle: String, firstID: UUID, secondTitle: String, secondID: UUID, searchText: String) -> Bool {
        let firstNormalized = normalized(firstTitle)

        let secondNormalized = normalized(secondTitle)

        let firstStartsWithSearch = firstNormalized.hasPrefix(searchText)

        let secondStartsWithSearch = secondNormalized.hasPrefix(searchText)

        if firstStartsWithSearch != secondStartsWithSearch {
            return firstStartsWithSearch
        }

        let comparison = firstTitle.localizedStandardCompare(secondTitle)

        if comparison != .orderedSame {
            return comparison == .orderedAscending
        }

        return firstID.uuidString < secondID.uuidString
    }
}
