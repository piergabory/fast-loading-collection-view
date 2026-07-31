import UIKit.UIImage
import CoreGraphics
import Foundation
import Immich
import ImmichAPI

actor PostGenerator {
    struct Failure: Error { }

    let scale: CGFloat = 2
    let frontSize = CGSize(width: 60, height: 80)
    let backSize = CGSize(width: 150, height: 200)

    @concurrent
    func generate(_ post: Post) async throws -> UIImage {
        let (frontData, backData) = try await getImageData(post)

        async let front = downsample(frontData, filling: frontSize)
        async let back = downsample(backData, filling: backSize)

        guard
            let front = await front,
            let back = await back
        else { throw Failure() }

        return await compose(front: front, back: back)
    }

    @concurrent
    func compose(front: UIImage, back: UIImage) async -> UIImage {
        let backFrame = CGRect(origin: .zero, size: backSize)
        let frontFrame = CGRect(origin: CGPoint(x: 2, y: 2), size: frontSize)

        return UIGraphicsImageRenderer(size: backSize).image { context in
            back.draw(in: backFrame)

            let cgctx = context.cgContext
            cgctx.setFillColor(UIColor.white.cgColor)
            cgctx.addRect(frontFrame.insetBy(dx: -1, dy: -1))
            cgctx.fillPath()

            front.draw(in: frontFrame)
        }
    }

    @concurrent
    func downsample(_ data: Data, filling pointSize: CGSize) async -> UIImage? {
        let sourceOptions = [kCGImageSourceShouldCache: false ] as CFDictionary
        let source = CGImageSourceCreateWithData(data as CFData, sourceOptions)
        guard let source else { return nil }

        let maximumPixelSize = min(pointSize.width, pointSize.height) * scale
        let thumbnailOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maximumPixelSize
        ] as CFDictionary

        let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions)
        return cgImage.flatMap { UIImage(cgImage: $0) }
    }

    @concurrent
    private func getImageData(_ post: Post) async throws -> (Data, Data) {
        async let frontRequest = Request.thumbnail(for: post.front.id)
        async let backRequest = Request.thumbnail(for: post.back.id)

        return (
            try await frontRequest,
            try await backRequest
        )
    }
}
