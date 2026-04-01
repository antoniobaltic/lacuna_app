import SwiftUI
import PhotosUI
import AVFoundation

struct PhotoContentEditor: View {
    @Binding var selectedPhoto: PhotosPickerItem?
    @Binding var imageData: Data?
    @Environment(StoreManager.self) private var storeManager
    @State private var photoTrigger = false
    @State private var showCamera = false
    @State private var showPaywall = false
    @State private var showCameraDenied = false
    @State private var clearTrigger = false
    @State private var cameraTrigger = false

    private var cameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    var body: some View {
        VStack(spacing: 16) {
            if let imageData, let uiImage = UIImage(data: imageData) {
                // Photo selected — show preview
                // Portrait photos get more height; landscape capped shorter
                let isPortrait = uiImage.size.height > uiImage.size.width
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: isPortrait ? 420 : 300)
                    .clipShape(.rect(cornerRadius: Design.radiusMedium))

                Button {
                    clearTrigger.toggle()
                    self.imageData = nil
                    self.selectedPhoto = nil
                } label: {
                    Text("choose another?")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .tracking(Design.trackingNormal)
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.impact(weight: .light), trigger: clearTrigger)
            } else {
                // No photo — show options
                HStack(spacing: 12) {
                    // Library option
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        PhotoOptionCard(icon: "photo.on.rectangle", label: "library")
                    }
                    .buttonStyle(.plain)

                    // Camera option (only if camera available)
                    if cameraAvailable {
                        Button {
                            cameraTrigger.toggle()
                            if storeManager.canUseCamera {
                                requestCameraAccess()
                            } else {
                                showPaywall = true
                            }
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                PhotoOptionCard(icon: "camera", label: "camera")
                                if !storeManager.canUseCamera {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.secondary)
                                        .padding(8)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .sensoryFeedback(.selection, trigger: cameraTrigger)
                    }
                }
            }
        }
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    imageData = Self.compressPhoto(data)
                    photoTrigger.toggle()
                }
            }
        }
        .onChange(of: imageData) { old, new in
            // Compress camera captures (camera sets raw data directly)
            if old == nil, let new, selectedPhoto == nil {
                let compressed = Self.compressPhoto(new)
                if compressed != new { imageData = compressed }
                photoTrigger.toggle()
            }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: photoTrigger)
        .sheet(isPresented: $showPaywall) {
            PaywallView(storeManager: storeManager, reason: .cameraGated)
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraImagePicker(imageData: $imageData)
                .ignoresSafeArea()
                .background(Color.black)
                .preferredColorScheme(.dark)
        }
        .alert("camera access needed", isPresented: $showCameraDenied) {
            Button("open settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("cancel", role: .cancel) {}
        } message: {
            Text("lacuna needs camera access to take photos for your time capsules. you can enable it in settings.")
        }
    }

    private func requestCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showCamera = true
        case .notDetermined:
            Task {
                let granted = await AVCaptureDevice.requestAccess(for: .video)
                if granted { showCamera = true }
                else { showCameraDenied = true }
            }
        case .denied, .restricted:
            showCameraDenied = true
        @unknown default:
            showCameraDenied = true
        }
    }

    private static func compressPhoto(_ data: Data, maxDimension: CGFloat = 2048, quality: CGFloat = 0.7) -> Data {
        guard let image = UIImage(data: data) else { return data }
        let size = image.size
        // Only resize if larger than max dimension
        if size.width <= maxDimension && size.height <= maxDimension {
            return image.jpegData(compressionQuality: quality) ?? data
        }
        let scale = maxDimension / max(size.width, size.height)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resized.jpegData(compressionQuality: quality) ?? data
    }

}

private struct PhotoOptionCard: View {
    let icon: String
    let label: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .ultraLight))
                .foregroundStyle(.primary)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .tracking(Design.trackingNormal)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .background(Design.surface)
        .clipShape(.rect(cornerRadius: Design.radiusMedium))
        .overlay {
            RoundedRectangle(cornerRadius: Design.radiusMedium)
                .strokeBorder(Design.border, lineWidth: 1)
        }
    }
}
