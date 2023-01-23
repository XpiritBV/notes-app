require './app/models/note.rb'
require './app/models/notebook.rb'

puts 'Seeding db...'

Note.destroy_all
Notebook.destroy_all

note = Note.create(title: "Welcome to Xpirit", body: "We're awesome")

book = Notebook.create(name: "Default")
book.notes.create(title: 'Super Cool Note', body: "Check it out")

book.notes << note
