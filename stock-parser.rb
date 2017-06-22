require 'csv'
require 'sequel'

# we could read and store in the database
# 1. store data in the database
# 2. do some crunching daily - send email
# format of the column:
# code, date, open, high, low, close, volume
rows = CSV.read('data/20170619.csv')

db = Sequel.connect('mysql2://root@localhost')
db.execute('CREATE DATABASE IF NOT EXISTS stocks')
db = Sequel.connect('mysql2://root@localhost/stocks')

