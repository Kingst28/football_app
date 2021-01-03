module ApplicationHelper
	def quid(price)
  		number_to_currency(price, :unit => "£")
	end

	def human_boolean(boolean)
		if boolean == false then
			return 'No'
		else
			return 'Yes'
		end
	end
end
