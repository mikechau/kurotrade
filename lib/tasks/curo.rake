require 'csv'

namespace :curo do

	task :loadticker => :environment do

		file = "doc/allsymbols-sample.csv"

		desc "Clear StockTicker Model and Load Stock Symbols into StockTicker"
		puts '=========================='
		puts 'StockTicker Seeder'
		puts '=========================='
		puts "DESTROYING PREVIOUS TABLE: #{StockTicker.count}"
	
		StockTicker.destroy_all

 		file_count = IO.readlines(file).size
 		count_total = file_count - 1

 		puts "This may take awhile..."
 		puts "Loading symbols into StockTicker: #{count_total}."

   	CSV.foreach(file, :headers => true, :col_sep => ';') do |row|
			stock = StockTicker.new
			stock.update_attributes(
      	:symbol => row.to_hash["Symbol"],
      	:name => row.to_hash["Description"],
      	:exchange => row.to_hash["Exchange"])
			file_count -=1
			puts "#{file_count} / #{count_total} Remaining!"
 		end

 		puts "STOCK SYMBOLS LOADED into StockTicker Model: #{StockTicker.count}"

	end

end


namespace :db do
  desc "Truncate all tables"
  task :truncate => :environment do
    conn = ActiveRecord::Base.connection
    tables = conn.execute("show tables").map { |r| r[0] }
    tables.delete "schema_migrations"
    tables.each { |t| conn.execute("TRUNCATE #{t}") }
  end
end

