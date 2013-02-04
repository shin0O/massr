# -*- coding: utf-8; -*-
require 'mongo_mapper'
require_relative 'statement'

module Massr
	class User
		include MongoMapper::Document

		# user status code
		ADMIN        = 0
		AUTHORIZED   = 1
		UNAUTHORIZED = 9

		key :massr_id,         :type => String , :required => true ,:unique => true
		key :twitter_user_id,  :type => String , :required => true ,:unique => true
		key :twitter_id,       :type => String , :required => true ,:unique => true
		key :twitter_icon_url, :type => String , :required => true
		key :name,             :type => String , :required => true
		key :email,            :type => String
		key :status,           :type => Integer, :default  => UNAUTHORIZED
		key :res_ids,          Array

		timestamps!

		many :ress ,            :class_name => 'Massr::Statement' , :in => :res_ids

		def self.create_by_registration_form(request)
			user = User.new(:massr_id => request[:massr_id])
			user.update_profile(request)
			return user
		end

		def self.change_status(id, status)
			user = User.find_by_massr_id(id)
			case status.to_s
			when ADMIN.to_s then
				user[:status] = ADMIN
			when AUTHORIZED.to_s then
				user[:status] = AUTHORIZED
			when UNAUTHORIZED.to_s then
				user[:status] = UNAUTHORIZED
			else
				return
			end
			user.save!
		end

		def self.each_authorized_user_without(me)
			where( :massr_id => {:$ne => me.massr_id},
					 :status => {:$ne => Massr::User::UNAUTHORIZED}).
					 sort(:updated_at.desc).each do |member|
				yield member
			end
		end

		def update_profile(request)
			self[:twitter_user_id] = request[:twitter_user_id]
			self[:twitter_id] = request[:twitter_id]
			self[:twitter_icon_url] = request[:twitter_icon_url]
			self[:name] = request[:name]
			self[:email] = request[:email]


			# 最初期のユーザは管理者として登録
			if User.all().count() == 0
				self[:status] = ADMIN
			end

			save!
			return self
		end

		def clear_res_ids
			self[:res_ids] = nil
			save!
			return self
		end

		def admin?
			status == ADMIN
		end

		def authorized?
			status != UNAUTHORIZED
		end

		def to_json(stat = nil)
			to_hash.to_json
		end

		def to_hash
			{
				'id' => id,
				'massr_id' => massr_id,
				'twitter_user_id' => twitter_user_id,
				'twitter_id' => twitter_id,
				'twitter_icon_url' => twitter_icon_url,
				'name' => name,
				'email' => email,
				'status' => status,
			}
		end
	end
end
