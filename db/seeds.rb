# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Faq.create(:question => 'What is a good question?', :answer => 'This is...', :module_id => 'CM2305', :coursework_id => 'CW130', :lecturer_id => 'C1529373')
Faq.create(:question => 'What is a bad question?', :answer => 'This is...', :module_id => 'CM2305', :coursework_id => 'CW130', :lecturer_id => 'C1529373')