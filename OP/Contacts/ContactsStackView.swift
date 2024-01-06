//
// Created for MyBooks
// by  Stewart Lynch on 2023-10-15
//
// Follow me on Mastodon: @StewartLynch@iosdev.space
// Follow me on Threads: @StewartLynch (https://www.threads.net)
// Follow me on X: https://x.com/StewartLynch
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch


import SwiftUI

struct ContactsStackView: View {
    var contacts: [Contact]
    var body: some View {
        HStack {
            ForEach(contacts.sorted(using: KeyPathComparator(\Contact.name))) { contact in
                Text(contact.name)
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(5)
                    .background(RoundedRectangle(cornerRadius: 5).fill(contact.hexColor))
            }
        }
    }
}

//#Preview {
//    GenresStackView()
//}
