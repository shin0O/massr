# -*- coding: utf-8; -*-
#
# routes/statement.rb
#
# Copyright (C) 2012 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#

module Massr
	class App < Sinatra::Base
		post '/statement' do
			statement = Statement.new

			request[:user] = User.find_by_id(session[:user_id])
			(request[:photos] ||= []) << picasa_upload(params[:photo]) if params[:photo]
			statement.update_statement( request ) unless request[:body].size == 0
			if statement.res && statement.res.user.email.length > 0
				send_mail(statement.res.user, statement)
			end
			redirect '/'
		end
		
		before '/statement/photos*' do
			@query = {"photos" => {:$ne => [] } }
		end

		get '/statement/photos' do
			haml :user_photos, :locals => {
				:statements => Statement.get_statements(param_date, @query),
				:q => nil}
		end

		get '/statement/photos.json' do
			[].tap {|a|
				Statement.get_statements(param_date, @query).each do |statement|
					a << statement.to_hash
				end
			}.to_json
		end

		get '/statement/:id.json' do
			Statement.find_by_id(params[:id]).to_hash.to_json
		end

		get '/statement/:id' do
			haml :user_statement, :locals => {:statement => Statement.find_by_id(params[:id])}
		end

		delete '/statement/:id' do
			if current_user == Statement.find_by_id(params[:id]).user
				Statement.destroy(params[:id])
			end
			redirect '/'
		end

		before '/statement/:id/like' do
			@user = User.find_by_id(session[:user_id])
			@statement = Statement.find_by_id(params[:id])
		end
		
		post '/statement/:id/like' do
			@statement.likes.delete_if{ |like| !like.user}
			unless @statement.like?(@user)
				like = Like.new(:user => @user)
				@statement.likes << like
			end
			@statement.save!
			@statement.to_hash.to_json
		end

		delete '/statement/:id/like' do
			@statement.likes.delete_if{ |like| !like.user}
			@statement.likes.delete_if{ |like| like.user.id == @user._id}
			@statement.save!
			@statement.to_hash.to_json
		end
	end
end

