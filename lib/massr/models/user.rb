# -*- coding: utf-8; -*-
require 'mongo_mapper'

module Massr
	class User
		include MongoMapper::Document
		safe
		
		key :massr_id,   :type => String,  :required => true ,:unique => true
		key :twitter_id, :type => String,  :required => true ,:unique => true
		key :name,       :type => String,  :required => true
		key :email,      :type => String,  :required => true

		timestamps!

		def self.create_by_registration_form( request )
			user = User.new
			user[:massr_id] = request[:id]
			user[:twitter_id] = request[:twitter_id]
			user[:name] = request[:name]
			user[:email] = request[:email]

			user.save!
			return user
		end
	end
end