# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ActiveSupport::JSON.decode(File.read("db/dictionary.json")).each do |word, definition|
  if not Entry.find_by word: word
    puts "word: #{word}, definition: #{definition}"
    Entry.create({ word: word, definition: definition })
  end
end