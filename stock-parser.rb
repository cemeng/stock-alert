require 'csv'
require 'sequel'

# we could read and store in the database
# 1. store data in the database
# 2. do some crunching daily - send email

DB = Sequel.connect('mysql2://root@localhost/financial')

def create_db
  DB.execute('CREATE DATABASE IF NOT EXISTS financial')
end

def create_stocks_table
  # index on code, date
  DB.create_table :stocks do
    String :code
    Date :date
    Decimal :open, size: [10, 2]
    Decimal :high, size: [10, 2]
    Decimal :low, size: [10, 2]
    Decimal :close, size: [10, 2]
    Integer :volume
    index :code
    unique [:code, :date]
  end
end

def delete_stocks_table
  DB.execute('DROP TABLE stocks')
end

def import(date: nil)
  # import from float.com.au -> put it on data
  stocks = DB[:stocks]
  CSV.read('data/20170619.csv').each do |row|
    # ["1AD", "20170619", "0.245", "0.245", "0.245", "0.245", "10000"]
    stocks.insert(code: row[0],
                  date: row[1],
                  open: row[2],
                  high: row[3],
                  low:  row[4],
                  close: row[5],
                  volume: row[6])
  end
end
