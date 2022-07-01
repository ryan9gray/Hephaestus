import Foundation
import UIKit

// swiftlint:disable for_where
// swiftlint:disable identifier_name

extension UICollectionView {
    func performBatchUpdates(
        old: [CollectionViewSection],
        new: [CollectionViewSection],
        diffable: Bool,
        updates: (() -> Void)
    ) {
        guard diffable else {
            updates()
            reloadData()
            return
        }

        let sections = DiffableArray.process(old: old, new: new)
        guard
            !sections.isEmpty,
            !sections.allSatisfy({ $0.isEmty })
        else { return }

        performBatchUpdates({
            updates()
            sections.forEach({ value in
                deleteItems(at: value)
                insertItems(at: value)
                moveItems(at: value)
            })
        }, completion: nil)

        sections.forEach({ value in
            reloadItems(at: value)
        })
    }
}

private extension UICollectionView {
    func deleteItems(at section: SectionDiffable) {
        guard !section.deletes.isEmpty else { return }
        deleteItems(at: section.deletes.map({ $0.at }))
        if section.action == .delete {
            deleteSections(IndexSet(integer: section.section))
        }
    }
}

private extension UICollectionView {
    func insertItems(at section: SectionDiffable) {
        guard !section.inserts.isEmpty else { return }
        if section.action == .insert {
            insertSections(IndexSet(integer: section.section))
        }
        insertItems(at: section.inserts.map({ $0.at }))
    }
}

private extension UICollectionView {
    func reloadItems(at section: SectionDiffable) {
        guard !section.reloades.isEmpty else { return }
        reloadItems(at: section.reloades.map({ $0.at }))
    }
}

private extension UICollectionView {
    func moveItems(at section: SectionDiffable) {
        section.moves.forEach({ item in
            moveItem(at: item.at, to: item.to)
        })
    }
}

private class DiffableArray {
    static func process(old: [CollectionViewSection], new: [CollectionViewSection]) -> [SectionDiffable] {
        let tuple = preprocess(old: old, new: new)
        let data = zip(
            tuple.old,
            tuple.new
        ).enumerated().map({ DiffableArray.diff(section: $0.offset, old: $0.element.0, new: $0.element.1) })
        return data
    }
}

private extension DiffableArray {
    static func preprocess(
        old: [CollectionViewSection],
        new: [CollectionViewSection]
    ) -> (new: [[CollectionViewItemProtocol]], old: [[CollectionViewItemProtocol]]) {
        let count = max(new.count, old.count)
        var newSections: [[CollectionViewItemProtocol]] = []
        var oldSections: [[CollectionViewItemProtocol]] = []
        for index in 0..<count {
            if new.indices.contains(index) {
                newSections.append(new[index].items)
            } else {
                newSections.append([])
            }
            if old.indices.contains(index) {
                oldSections.append(old[index].items)
            } else {
                oldSections.append([])
            }
        }
        return (newSections, oldSections)
    }
}

private extension DiffableArray {
    static func diff(
        section: Int,
        old: [CollectionViewItemProtocol],
        new: [CollectionViewItemProtocol]
    ) -> SectionDiffable {
        let prediffable = DiffableArray.prediffable(section: section, old: old, new: new)
        guard prediffable.isEmty else { return prediffable }

        let oldIds = Set(old.map({ $0.diff.id }))
        let newIds = Set(new.map({ $0.diff.id }))

        let deleteIds = oldIds.subtracting(newIds)
        let insertIds = newIds.subtracting(oldIds)

        let deletes = old.enumerated()
            .filter({ deleteIds.contains($0.element.diff.id) })
            .map({ SectionDiffable.Delete(at: IndexPath(row: $0.offset, section: section)) })

        let inserts = new.enumerated()
            .filter({ insertIds.contains($0.element.diff.id) })
            .map({ SectionDiffable.Insert(at: IndexPath(row: $0.offset, section: section)) })

        var reloades = [SectionDiffable.Reload]()
        var moves = [SectionDiffable.Move]()

        for oldSnapshot in old.enumerated() {
            for newSnapshot in new.enumerated() {
                if oldSnapshot.element.diff.id == newSnapshot.element.diff.id {
                    if oldSnapshot.element.diff.snapshot != newSnapshot.element.diff.snapshot {
                        reloades.append(
                            SectionDiffable.Reload(
                                at: IndexPath(row: newSnapshot.offset, section: section)
                            )
                        )
                    }
                    if oldSnapshot.offset != newSnapshot.offset {
                        moves.append(
                            SectionDiffable.Move(
                                at: IndexPath(row: oldSnapshot.offset, section: section),
                                to: IndexPath(row: newSnapshot.offset, section: section)
                            )
                        )
                    }
                }
            }
        }

        return SectionDiffable(
            reloades: reloades,
            inserts: inserts,
            deletes: deletes,
            moves: moves,
            action: prediffable.action,
            section: section
        )
    }
}

private extension DiffableArray {
    static func prediffable(
        section: Int,
        old: [CollectionViewItemProtocol],
        new: [CollectionViewItemProtocol]
    ) -> SectionDiffable {
        let action: SectionDiffable.Action = {
            switch (old.isEmpty, new.isEmpty) {
            case (true, false):
                return .insert
            case (false, true):
                return .delete
            default:
                return .none
            }
        }()
        let empty = SectionDiffable(reloades: [], inserts: [], deletes: [], moves: [], action: action, section: section)
        guard !old.filter({ $0.diff == .zero }).isEmpty ||
                !new.filter({ $0.diff == .zero }).isEmpty else { return empty }
        let deletes = old.enumerated().map({ SectionDiffable.Delete(at: IndexPath(row: $0.offset, section: section)) })
        let inserts = new.enumerated().map({ SectionDiffable.Insert(at: IndexPath(row: $0.offset, section: section)) })
        return SectionDiffable(
            reloades: [],
            inserts: inserts,
            deletes: deletes,
            moves: [],
            action: action,
            section: section
        )
    }
}

private struct SectionDiffable {
    struct Reload {
        var at: IndexPath
    }

    struct Insert {
        var at: IndexPath
    }

    struct Delete {
        var at: IndexPath
    }

    struct Move {
        var at: IndexPath
        var to: IndexPath
    }

    enum Action {
        case insert
        case delete
        case none
    }

    let reloades: [Reload]
    let inserts: [Insert]
    let deletes: [Delete]
    let moves: [Move]

    let action: Action
    let section: Int

    var isEmty: Bool {
        return reloades.isEmpty &&
            inserts.isEmpty &&
            deletes.isEmpty &&
            moves.isEmpty
    }
}
