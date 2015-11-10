# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# TODO: password is "chanethis", make it not this
User.create(name: 'Blake McIntyre',
            email: 'blake.mcintyre@gmail.com',
            admin: true,
            password_digest: '$2a$10$EIq01RJaQt8GQY27UnTFJO2d5gYjgPvvQjjYAEuDFcUi2.ICBR9da')

if Rails.env.development?
  User.create(name: 'Foo Bar', email: 'foo@test.com', password: 'test1234')
  User.create(name: 'Baz Boo', email: 'baz@test.com', password: 'test1234')
end
