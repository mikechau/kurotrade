require 'csv'

namespace :curo do

	task :loadticker => :environment do

		file = "doc/allsymbols.csv"

		desc "Clear StockTicker Model and Load Stock Symbols into StockTicker"
		puts 'KURO DB INITIALIZER: V.0.1'
		puts '=========================='
		puts "DESTROYING PREVIOUS TABLE: #{StockTicker.count}"
	
		StockTicker.destroy_all

 		file_count = IO.readlines(file).size
 		puts "Loading symbols into StockTicker: #{file_count}"

   	CSV.foreach(file, :headers => true, :col_sep => ';') do |row|
			stock = StockTicker.new
			stock.update_attributes(
      	:symbol => row.to_hash["Symbol"],
      	:name => row.to_hash["Description"],
      	:exchange => row.to_hash["Exchange"])
			file_count_remaining -=1
			puts "#{file_count_remaining} / #{file_count} Remaining!"
 			end
 		puts "STOCK SYMBOLS LOADED into StockTicker Model: #{StockTicker.count}"
	end
end