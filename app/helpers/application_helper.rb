module ApplicationHelper
	def quid(price)
  		number_to_currency(price, :unit => "£")
	end

	def human_boolean(boolean)
		boolean ? 'Yes' : 'No'
	end
end
