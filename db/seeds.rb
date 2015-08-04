# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
puts 'creating pool...'
pool = Pool.create(:group_id => -1, :bot_id => -1)

puts 'creating users...'
alan = User.create(:user_id => 1, :name => 'Alan Wei')
john = User.create(:user_id => 2, :name => 'John White')
matt = User.create(:user_id => 3, :name => 'Matt Krieg')
bart = User.create(:user_id => 4, :name => 'Bartholemew Gonzalez')
pj = User.create(:user_id => 5, :name => 'PJ Harris')
caroline = User.create(:user_id => 6, :name => 'Caroline Barton')
sid = User.create(:user_id => 7, :name => 'Sid Pailla')

puts 'registering users...'
User.register(pool, alan)
User.register(pool, john)
User.register(pool, matt)
User.register(pool, bart)
User.register(pool, pj)
User.register(pool, caroline)
User.register(pool, sid)

puts 'starting pool...'
pool.start