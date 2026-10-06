#if os(iOS)
import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

/// PHPicker grants access only to selected assets; no photo-library permission is required.
struct AttachmentPhotoPicker: UIViewControllerRepresentable {
    let onComplete: ([URL], String?) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0
        configuration.filter = .any(of: [.images, .videos])
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ controller: PHPickerViewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(onComplete: onComplete) }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onComplete: ([URL], String?) -> Void
        init(onComplete: @escaping ([URL], String?) -> Void) { self.onComplete = onComplete }
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            Task { @MainActor in
                var urls: [URL] = []
                var failures: [String] = []
                for result in results {
                    let provider = result.itemProvider
                    guard let type = provider.registeredTypeIdentifiers.first(where: {
                        guard let type = UTType($0) else { return false }
                        return type.conforms(to: .image) || type.conforms(to: .movie)
                    }) else { failures.append("This photo or video could not be read."); continue }
                    do {
                        let url: URL = try await withCheckedThrowingContinuation { continuation in
                            provider.loadFileRepresentation(forTypeIdentifier: type) { url, error in
                                guard let url else {
                                    continuation.resume(throwing: error ?? UIConfigurationError("Unable to load selected media"))
                                    return
                                }
                                // The provider removes its URL after this callback, so copy it here.
                                let folder = FileManager.default.temporaryDirectory.appendingPathComponent("ArtemisPhoto-\(UUID().uuidString)", isDirectory: true)
                                do {
                                    try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
                                    let destination = folder.appendingPathComponent(url.lastPathComponent)
                                    try FileManager.default.copyItem(at: url, to: destination)
                                    continuation.resume(returning: destination)
                                } catch {
                                    try? FileManager.default.removeItem(at: folder)
                                    continuation.resume(throwing: error)
                                }
                            }
                        }
                        urls.append(url)
                    } catch { failures.append(error.localizedDescription) }
                }
                onComplete(urls, failures.isEmpty ? nil : failures.joined(separator: "\n"))
            }
        }
    }
}

struct AttachmentCameraPicker: UIViewControllerRepresentable {
    let onComplete: (URL?, String?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = ["public.image"]
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ controller: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(onComplete: onComplete) }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onComplete: (URL?, String?) -> Void

        init(onComplete: @escaping (URL?, String?) -> Void) {
            self.onComplete = onComplete
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onComplete(nil, nil)
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            guard let image = info[.originalImage] as? UIImage,
                  let data = image.jpegData(compressionQuality: 0.9) else {
                onComplete(nil, "Unable to read the captured photo.")
                return
            }

            do {
                let folder = FileManager.default.temporaryDirectory.appendingPathComponent("ArtemisCamera-\(UUID().uuidString)", isDirectory: true)
                try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
                let url = folder.appendingPathComponent("photo.jpg")
                try data.write(to: url, options: .atomic)
                onComplete(url, nil)
            } catch {
                onComplete(nil, error.localizedDescription)
            }
        }
    }
}
#endif
