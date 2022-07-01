//
//  CollectionViewHeaderAndFooterSizer.swift
//  
//
//  Created by Gleb Uvarkin on 11.02.2021.
//

import UIKit

public class CollectionViewHeaderAndFooterSizer {
    public var contentSizeCategory: UIContentSizeCategory = UIApplication.shared.preferredContentSizeCategory

    private var cachedHeights: [UIContentSizeCategory: [String: [Int: CGFloat]]] = [:]

    public init() {}

    /// Pass here ONLY configured copy of Header or Footer.
    /// In order not to create view every time, you can check if cached size exists by not passing view argument.
    /// It will return size if exists and nil otherwise

    public func calculateSize(
        kind: String,
        section: Int,
        availableWidth: CGFloat,
        view: UICollectionReusableView? = nil
    ) -> CGSize? {
        let cachedHeight = cachedHeights[contentSizeCategory]?[kind]?[section]
        if let height = cachedHeight, height != 0 {
            return CGSize(width: availableWidth, height: height)
        }

        guard let view = view else { return nil }

        view.layoutIfNeeded()
        let targetSize = CGSize(width: availableWidth, height: UIView.layoutFittingCompressedSize.height)
        let height = view.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        if cachedHeights[contentSizeCategory] == nil {
            cachedHeights[contentSizeCategory] = [:]
        }

        if cachedHeights[contentSizeCategory]?[kind] == nil {
            cachedHeights[contentSizeCategory]?[kind] = [:]
        }

        cachedHeights[contentSizeCategory]?[kind]?[section] = height

        return CGSize(width: availableWidth, height: height)
    }

    public func removeCache() {
        cachedHeights.removeAll()
    }
}
