require 'csv'
require 'sequel'
require 'net/http'
require 'uri'

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

def download(date:)
  uri = URI.parse("http://float.com.au/download/#{date}.csv")
  Net::HTTP.get_response(uri).response.body
end

def import(date: nil)
  stocks = DB[:stocks]
  stocks_csv = download(date: date) # offline: CSV.read('data/20170619.csv')
  CSV.parse(stocks_csv).each do |row|
    stocks.insert(code: row[0],
                  date: row[1],
                  open: row[2],
                  high: row[3],
                  low:  row[4],
                  close: row[5],
                  volume: row[6])
  end
end

puts "importing #{ARGV[0]}"
# check if date is weekend or public holiday don't do it
import(date: ARGV[0])
puts "importing finished"
