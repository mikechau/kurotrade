require 'csv'

task :loadticker => :environment do
	desc "Clear StockTicker Model and Load Stock Symbols into StockTicker"
	puts 'KURO DB INITIALIZER: V.0.1'
	puts '=========================='
	puts 'DESTROYING PREVIOUS TABLE'
	
	StockTicker.destroy_all
  
  CSV.foreach("doc/allsymbols.csv", :headers => true, :col_sep => ';') do |row|
		stock = StockTicker.new
		stock.update_attributes(
      :symbol => row.to_hash["Symbol"],
      :company => row.to_hash["Description"],
      :exchange => row.to_hash["Exchange"])
 		end
 	puts "STOCK SYMBOLS LOADED into StockTicker Model: #{StockTicker.count}"
end