# Privacy Policy

**Lacuna — Time Capsule App**

Last updated: April 1, 2026

Antonio Baltic ("I", "me", "my") operates the Lacuna mobile application ("the App"). This privacy policy explains how your information is handled when you use the App.

**The short version: Lacuna stores everything locally on your device. I don't collect, transmit, or have access to any of your data. I can't see your capsules, photos, voice notes, or any other content you create.**

---

## 1. Data Controller

Antonio Baltic
Austria

Email: antoniobaltic@icloud.com

For the purposes of the EU General Data Protection Regulation (GDPR / DSGVO) and the Austrian Datenschutzgesetz (DSG), I am the data controller.

---

## 2. What Data Is Processed

### 2.1 Content You Create (Stored Locally Only)

When you create a capsule, the following data is stored **exclusively on your device**:

- Text content you write
- Photos you select from your library or capture with the camera
- Voice recordings you make
- Capsule titles, creation dates, and unlock dates
- Your sender name (if you choose to send a capsule to someone)

**This data never leaves your device** unless you explicitly choose to share a capsule with someone using the App's send feature (see Section 2.3).

I have no access to any of this data. There are no servers, no cloud storage, no accounts, and no way for me or any third party to view your content.

### 2.2 Preferences (Stored Locally Only)

The App stores your preferences on your device using Apple's standard storage:

- Appearance mode (light, dark, or automatic)
- Your sender name (so you don't have to re-enter it each time you send)
- Onboarding completion status
- Notification permission status

These preferences are not transmitted anywhere.

### 2.3 Shared Capsules

When you use the "send to someone" feature, the App packages your capsule content into a `.capsule` file and opens the iOS share sheet. You choose how to share it (e.g., AirDrop, iMessage, email).

- The file is created locally on your device
- It is shared through Apple's standard sharing mechanisms
- I have no involvement in or access to the transmission
- The recipient's copy is stored locally on their device
- Your sender name is included in the file so the recipient knows who sent it

The sharing is entirely peer-to-peer. No data passes through any server I operate.

### 2.4 In-App Purchases

The App offers a one-time in-app purchase ("Lacuna +") processed by Apple through the App Store. Purchase validation and entitlement management is handled by **RevenueCat**, a third-party service (see Section 5). RevenueCat receives:

- A randomly generated anonymous user ID (not linked to your Apple ID or any personal information)
- Purchase transaction data from Apple (product purchased, date, transaction ID)
- Your device's country/region (for currency and pricing purposes)

RevenueCat does **not** receive your name, Apple ID, email address, payment details, or any other personally identifiable information. The anonymous user ID cannot be used to identify you.

I receive aggregate, anonymized sales data (e.g., number of purchases per country) from both Apple and RevenueCat. I do **not** receive any data that could identify individual users.

### 2.5 Notifications

The App uses Apple's local notification system to alert you when a capsule is ready to open. These notifications are:

- Scheduled locally on your device
- Not routed through any external server
- Not used for marketing or advertising

### 2.6 Data I Do NOT Collect

To be explicit, the App does **not** collect or process:

- Personal identification information (name, email, phone number)
- Location data
- Device identifiers or fingerprints
- Usage analytics or behavioral data
- Crash reports or diagnostics
- Advertising identifiers
- Cookies or tracking technologies
- Health, financial, or biometric data

---

## 3. Legal Basis for Processing (GDPR Article 6)

The minimal data processing that occurs is based on:

- **Article 6(1)(b) — Performance of a contract**: Processing your locally stored content is necessary to provide the App's functionality (creating, sealing, and opening capsules). This also covers the transmission of anonymous purchase data to RevenueCat, which is necessary to validate and deliver the in-app purchase you initiated.
- **Article 6(1)(a) — Consent**: Notification permissions and camera/microphone/photo library access are granted explicitly by you through iOS system prompts. You can revoke these at any time in your device settings.

---

## 4. Data Storage and Security

All data is stored locally on your device using Apple's standard frameworks:

- **SwiftData** for capsule metadata and content
- **File system** for voice recordings (stored in the App's sandboxed Documents directory)
- **UserDefaults** for preferences

Data is protected by your device's built-in security features, including:

- Device encryption (enabled by default on all modern iOS devices)
- App sandboxing (other apps cannot access Lacuna's data)
- Biometric/passcode device lock

I do not implement additional encryption because your device's native encryption already protects all locally stored data.

---

## 5. Data Sharing and Third Parties

The App does not share your personal data with any third parties. The App contains:

- No analytics SDKs
- No advertising frameworks
- No social media tracking

The App uses two third-party services, neither of which receives your personal data:

- **Apple** processes in-app purchases through the App Store under Apple's own privacy policy: https://www.apple.com/legal/privacy/
- **RevenueCat, Inc.** manages purchase validation and entitlement status. RevenueCat receives only an anonymous, randomly generated user ID and purchase transaction data. RevenueCat's privacy policy: https://www.revenuecat.com/privacy/

RevenueCat acts as a data processor on my behalf under GDPR Article 28. No personal data (name, email, Apple ID, device identifiers) is transmitted to RevenueCat. The anonymous user ID used by RevenueCat is generated locally and cannot be linked to your identity.

---

## 6. Data Retention and Deletion

Your data is retained on your device for as long as you keep it:

- **Capsules**: Stored until you delete them within the App
- **Preferences**: Stored until you delete the App
- **Voice recordings**: Stored as files until the associated capsule is deleted

**To delete all data permanently**, simply delete the App from your device. This removes all locally stored data completely and irreversibly.

You can also delete individual capsules within the App at any time.

Note: If you made an in-app purchase, RevenueCat retains the anonymous purchase record (anonymous user ID and transaction data) for the purpose of restoring your purchase on a new device. This data cannot be linked to your identity. RevenueCat's data retention practices are governed by their privacy policy: https://www.revenuecat.com/privacy/

---

## 7. Your Rights Under GDPR / DSGVO

Under the General Data Protection Regulation and the Austrian Datenschutzgesetz, you have the following rights:

- **Right of access** (Article 15 GDPR): You can view all your data directly within the App at any time.
- **Right to rectification** (Article 16 GDPR): You can modify capsule titles within the App. Sealed capsule content cannot be modified by design — this is a core feature, not a limitation.
- **Right to erasure** (Article 17 GDPR): You can delete any capsule at any time, or delete the App entirely to remove all data.
- **Right to data portability** (Article 20 GDPR): You can export capsules as `.capsule` files using the send feature.
- **Right to restriction of processing** (Article 18 GDPR): Since all processing is local and under your control, you can restrict processing by simply not using the App.
- **Right to object** (Article 21 GDPR): There is no profiling, automated decision-making, or direct marketing to object to.
- **Right to withdraw consent** (Article 7(3) GDPR): You can revoke camera, microphone, photo library, and notification permissions at any time in your iOS Settings.

Since I do not store any of your data on servers or have any way to access it, most of these rights are automatically fulfilled by the App's local-only architecture.

---

## 8. International Data Transfers

Your capsule content (text, photos, voice recordings) is never transferred to any server. It remains on your device in the jurisdiction where you use it.

When you make an in-app purchase, anonymous transaction data (anonymous user ID, product purchased, transaction ID) is processed by RevenueCat, Inc., which is based in the United States. This transfer is limited to non-personal, anonymous data and is covered by RevenueCat's data processing agreements and standard contractual clauses under GDPR Article 46.

When you share a capsule with someone using the send feature, the data transfer occurs through the communication channel you choose (e.g., iMessage, email) and is governed by that service's privacy policy and the applicable laws of the jurisdictions involved.

---

## 9. Children's Privacy

The App does not knowingly collect any data from children under the age of 16 (the age threshold under GDPR). Since the App does not collect any personal data from any user, no special measures for children's data are required.

---

## 10. Austrian-Specific Provisions (DSG)

In accordance with the Austrian Datenschutzgesetz (DSG) implementing the GDPR:

- The responsible data protection authority is the **Österreichische Datenschutzbehörde** (Austrian Data Protection Authority), Barichgasse 40-42, 1030 Wien, Austria. Website: https://www.dsb.gv.at
- You have the right to lodge a complaint with the Datenschutzbehörde if you believe your data protection rights have been violated.
- As the App processes no personal data on external servers, no Data Protection Impact Assessment (DPIA) is required under Article 35 GDPR.
- No Data Protection Officer (DPO) is appointed as I am an individual developer not engaged in large-scale processing of personal data (Article 37 GDPR).

---

## 11. Apple App Store Requirements

In accordance with Apple's App Store Review Guidelines:

- The App's privacy nutrition label on the App Store declares "Purchases" and "Identifiers" (anonymous ID) as data used, marked as **not linked to your identity**, in accordance with RevenueCat's data processing for purchase validation.
- The App requests camera, microphone, and photo library permissions only when needed and explains the purpose in the permission dialogs.
- The App does not use any Apple frameworks for tracking or advertising.

---

## 12. Changes to This Privacy Policy

I may update this privacy policy from time to time. Any changes will be reflected by updating the "Last updated" date at the top of this policy. Since I have no way to contact you (I don't have your email or any contact information), I encourage you to review this policy periodically.

Significant changes will also be noted in the App Store release notes when the App is updated.

---

## 13. Contact

If you have any questions about this privacy policy, your rights, or the App's data practices, please contact me at:

**Email**: antoniobaltic@icloud.com

I will respond to privacy-related inquiries within 30 days, as required by GDPR Article 12(3).

---

## 14. Summary

| Question | Answer |
|----------|--------|
| Do you collect my data? | No |
| Do you have servers? | No |
| Can you see my capsules? | No |
| Do you use analytics? | No |
| Do you track me? | No |
| Do you share data with third parties? | Anonymous purchase data only (RevenueCat) |
| Where is my data stored? | On your device only |
| How do I delete my data? | Delete the capsule or delete the App |

---

*This privacy policy is governed by the laws of Austria and the European Union.*
