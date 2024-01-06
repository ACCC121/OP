//
// Created for Myopportunity
// by  Stewart Lynch on 2023-10-15
//
// Follow me on Mastodon: @StewartLynch@iosdev.space
// Follow me on Threads: @StewartLynch (https://www.threads.net)
// Follow me on X: https://x.com/StewartLynch
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch

import SwiftData
import SwiftUI

struct ContactsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Bindable var opportunity: Opportunity
    @Query(sort: \Contact.name) var contacts: [Contact]
    @State private var newContact = false
    var body: some View {
        NavigationStack {
            Group {
                if contacts.isEmpty {
                    ContentUnavailableView {
                        Image(systemName: "opportunityark.fill")
                            .font(.largeTitle)
                    } description: {
                        Text("You need to create some contacts first.")
                    } actions: {
                        Button("Create contact") {
                            newContact.toggle()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(contacts) { contact in
                            HStack {
                                if let opportunityContacts = opportunity.contacts {
                                    if opportunityContacts.isEmpty {
                                        Button {
                                            addRemove(contact)
                                        } label: {
                                            Image(systemName: "circle")
                                        }
                                        .foregroundStyle(contact.hexColor)
                                    } else {
                                        Button {
                                            addRemove(contact)
                                        } label: {
                                            Image(systemName: opportunityContacts.contains(contact) ? "circle.fill" : "circle")
                                        }
                                        .foregroundStyle(contact.hexColor)
                                    }
                                }
                                Text(contact.name)
                            }
                        }
                        .onDelete(perform: { indexSet in
                            indexSet.forEach { index in
                                if let opportunitiesContacts = opportunity.contacts,
                                   opportunitiesContacts.contains(contacts[index]),
                                   let opportunitiesContactIndex = opportunitiesContacts.firstIndex(where: {$0.id == contacts[index].id}) {
                                    opportunity.contacts?.remove(at: opportunitiesContactIndex)
                                }
                                context.delete(contacts[index])
                            }
                        })
                        LabeledContent {
                            Button {
                                newContact.toggle()
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .imageScale(.large)
                            }
                            .buttonStyle(.borderedProminent)
                        } label: {
                            Text("Create new contact")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(opportunity.title)
            .sheet(isPresented: $newContact) {
                NewContactView()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func addRemove(_ contact: Contact) {
        if let opportunityContact = opportunity.contacts {
            if opportunityContact.isEmpty {
                opportunity.contacts?.append(contact)
            } else {
                if opportunityContact.contains(contact),
                   let index = opportunityContact.firstIndex(where: {$0.id == contact.id}) {
                    opportunity.contacts?.remove(at: index)
                } else {
                    opportunity.contacts?.append(contact)
                }
            }
        }
    }
}

#Preview {
    let preview = Preview(Opportunity.self)
    let opportunity = Opportunity.sampleOpportunities
    let contacts = Contact.sampleContacts
    preview.addExamples(contacts)
    preview.addExamples(opportunity)
    opportunity[1].contacts?.append(contacts[0])
    return ContactsView(opportunity: opportunity[1])
        .modelContainer(preview.container)
}
