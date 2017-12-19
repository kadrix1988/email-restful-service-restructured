class SessionsController < ApplicationController
 #  	def create
 #  		puts "hello\n\n"
 #  		puts account_params
 #    	@user = User.find_by("LOWER(email) = ?", account_params[:email].downcase)
 #    	if @user.present? && @user.authenticate(account_params[:password])
 #      		session[@user.email.to_s] = @user.id
 #      		puts session
 #      		render json: {success: true, session_key: @user.id}
 #    	else
 #      		render json: {success: false}
 #    	end
 #  	end

 #  	def logged_in
 #  		puts "session key: #{allowed_params[:session_key].to_i}"
 #  		puts "session inspect: #{session.inspect}"
 #  		puts session[allowed_params[:session_key].to_i]
 #  		if session[allowed_params[:session_key].to_i].present?
 #  			render json: {"working?": "YES"}
 #  		end
 #  		render json: {"working?": "NO"}
 #  	end

	# def destroy
	# 	session.delete(:current_user_id)
	# 	render json: {success: true}
	# end

	# private

	# def account_params
	# 	params.permit(:email, :password)
	# end

	# def allowed_params
	# 	params.permit(:session_key)
	# end
end
