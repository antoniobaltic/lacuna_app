import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NotificationManager.self) private var notificationManager
    @State private var doneTrigger = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Custom header
                HStack {
                    Text("privacy policy")
                        .font(.title3.weight(.medium))
                        .tracking(Design.trackingWide)

                    Spacer()

                    Button {
                        doneTrigger.toggle()
                        dismiss()
                    } label: {
                        Text("done")
                            .font(.body.weight(.medium))
                            .tracking(Design.trackingNormal)
                            .foregroundStyle(Design.bg)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Design.fg)
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.impact(weight: .light), trigger: doneTrigger)
                }
                .padding(.top, 24)

                VStack(spacing: 28) {
                    // Summary box
                    VStack(spacing: 12) {
                        Text("lacuna stores everything locally on your device. we don't collect, transmit, or have access to any of your data.")
                            .font(.subheadline)
                            .tracking(Design.trackingTight)
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(Design.surface)
                    .clipShape(.rect(cornerRadius: Design.radiusLarge))
                    .overlay {
                        RoundedRectangle(cornerRadius: Design.radiusLarge)
                            .strokeBorder(Design.border, lineWidth: 1)
                    }

                    // Sections
                    policySection("data controller") {
                        "Antonio Baltic\naustria\nantoniobaltic@icloud.com"
                    }

                    policySection("where your data lives") {
                        """
                        all capsule data (text, photos, voice recordings, titles, dates) is stored on your device using apple's swiftdata framework.

                        if icloud is enabled, your capsules sync automatically across your apple devices using apple's cloudkit. this data goes to your personal icloud storage — not to any server we operate. apple encrypts it in transit and at rest.

                        your preferences (appearance mode, sender name, onboarding status) are stored locally and are not synced.

                        we have no servers, no accounts, and no way to access your content.
                        """
                    }

                    policySection("shared capsules") {
                        """
                        when you send a capsule to someone, the app packages it into a .capsule file and opens the ios share sheet. you choose how to share it (airdrop, imessage, email, etc.).

                        the file is created locally. sharing happens through apple's standard mechanisms. no data passes through any server we operate. the transfer is entirely peer-to-peer.
                        """
                    }

                    policySection("in-app purchases") {
                        """
                        lacuna + is processed by apple through the app store. purchase validation is handled by revenuecat, a third-party service that receives only a randomly generated anonymous id and transaction data. revenuecat does not receive your name, apple id, email, or payment details.

                        we receive only aggregate, anonymized sales data. we do not receive any information that could identify individual users.
                        """
                    }

                    policySection("notifications") {
                        """
                        the app uses apple's local notification system to alert you when a capsule is ready. notifications are scheduled locally on your device, not routed through any external server, and not used for marketing.
                        """
                    }

                    policySection("what we do not collect") {
                        """
                        we do not collect: personal identification information, location data, device identifiers, usage analytics, crash reports, advertising identifiers, cookies, tracking technologies, health data, financial data, or biometric data.

                        the app contains no analytics sdks, no advertising frameworks, and no social media tracking. the only third-party service is revenuecat for anonymous purchase validation (see above).
                        """
                    }

                    policySection("your rights (gdpr / dsgvo)") {
                        """
                        under the general data protection regulation and the austrian datenschutzgesetz, you have the right to access, rectify, erase, port, and restrict processing of your data.

                        since all data is stored locally on your device, these rights are automatically fulfilled — you can view, delete, or export your data at any time within the app.

                        to delete all data permanently, delete the app from your device.

                        the responsible authority is the österreichische datenschutzbehörde, barichgasse 40-42, 1030 wien. dsb.gv.at
                        """
                    }

                    policySection("data security") {
                        """
                        your data is protected by your device's built-in encryption, app sandboxing, and biometric/passcode lock. no additional encryption is implemented because ios device encryption already protects all locally stored data.
                        """
                    }

                    policySection("children") {
                        """
                        the app does not knowingly collect any data from children under 16. since the app collects no personal data from any user, no special measures are required.
                        """
                    }

                    policySection("changes") {
                        """
                        this policy may be updated. changes will be reflected by the date below and noted in app store release notes.
                        """
                    }

                    // Summary table
                    VStack(spacing: 12) {
                        summaryRow("collect your data?", answer: "no")
                        Divider().overlay(Design.divider)
                        summaryRow("have servers?", answer: "no")
                        Divider().overlay(Design.divider)
                        summaryRow("see your capsules?", answer: "no")
                        Divider().overlay(Design.divider)
                        summaryRow("use analytics?", answer: "no")
                        Divider().overlay(Design.divider)
                        summaryRow("track you?", answer: "no")
                        Divider().overlay(Design.divider)
                        summaryRow("share with third parties?", answer: "anonymous purchase data only")
                        Divider().overlay(Design.divider)
                        summaryRow("where is data stored?", answer: "device + your icloud")
                        Divider().overlay(Design.divider)
                        summaryRow("how to delete?", answer: "delete the app")
                    }
                    .padding(20)
                    .background(Design.surface)
                    .clipShape(.rect(cornerRadius: Design.radiusLarge))
                    .overlay {
                        RoundedRectangle(cornerRadius: Design.radiusLarge)
                            .strokeBorder(Design.border, lineWidth: 1)
                    }

                    // Footer
                    VStack(spacing: 6) {
                        Text("last updated: april 4, 2026")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .tracking(Design.trackingTight)
                        Text("governed by the laws of austria and the european union.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .tracking(Design.trackingTight)
                        Text("antoniobaltic@icloud.com")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .tracking(Design.trackingTight)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
            .padding(.horizontal, 24)
        }
        .background(Design.bg.ignoresSafeArea())
        .scrollContentBackground(.hidden)
        .overlay { FloatingParticlesView().ignoresSafeArea() }
        .onChange(of: notificationManager.pendingCapsuleID) { _, id in
            if id != nil { dismiss() }
        }
    }

    private func policySection(_ title: String, content: () -> String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .tracking(Design.trackingNormal)

            Text(content())
                .font(.caption)
                .foregroundStyle(.secondary)
                .tracking(Design.trackingTight)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func summaryRow(_ question: String, answer: String) -> some View {
        HStack {
            Text(question)
                .font(.caption)
                .foregroundStyle(.secondary)
                .tracking(Design.trackingTight)
            Spacer()
            Text(answer)
                .font(.caption.weight(.medium))
                .tracking(Design.trackingNormal)
        }
    }
}
