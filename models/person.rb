class Person < ActiveRecord::Base
	#has_many :relationships

	attr_reader :private_id, :attributes

	def initialize id, attributes
		@private_id = id
		@attributes = attributes
	end
end
