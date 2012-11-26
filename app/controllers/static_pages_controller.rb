class StaticPagesController < ApplicationController

	def index
	end

	def balance_exp
		@transactions_initial = Transaction.order(:trade_date)
		@transactions = @transactions_initial.where(:user_id => 1)

		# @initial_nav_value = 0
		# @initial_nav_units = 1000
	end
end

# NAV UNITS: 
#   WITHDRAWAL: #PAYMENT ON ACCCOUNT
# Previous NAV - ( -Withdrawl / [ ( Cash + Stock Value - Withdrawal ) / Previous NAV) ] )

#1000 - (-Withdrawl / [])

#   DEPOSIT: #DEPOSIT CKS
# 	Previous NAV + ( Deposit / [ ( Cash + Stock Value - Deposit ) / Previous NAV) ] )