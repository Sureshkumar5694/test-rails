class UsersController < ApplicationController

	before_action :set_user, only: [:authenticate_otp]

	def create		
		 user = User.where(mobile_number: params[:mobile_number]).first_or_initialize

		 user.generate_otp if user.is_otp_expired?	
		 user.save! 
		 session[:mobile_number] = params[:mobile_number]
		redirect_to otp_users_path
	end	

	def login		
		session[:cid] = params[:client_mac]	
		session[:ap] = params[:ap]
		session[:ssid] = params[:ssid]
		session[:t] = params[:t]
		session[:rid] = params[:rid]
		session[:site] = params[:site]

		# session[:clientMac] = params[:clientMac]
		# session[:radiusSvrIp] = "192.168.1.48"
		# session[:target] = params[:target]
	end	

	def otp
		
	end

	def authenticate_otp
		otp = params[:otp]
		# unless @user.verify_otp?(otp)
		  api = ControllerApi.new 
		  req_params = { name: 'admin', password: 'ajira12345'}
			response = api.post('https://18.220.161.97:8043/login', body: req_params, verify: false)
			binding.pry
	    	    	    
			req_params = { cid: params[:cid], ap: session[:ap], ssid: session[:ssid],rid: session[:rid], site: session[:site], t: session[:t], time: "1800" }
			response = api.post('https://18.220.161.97:8043/extportal/site_name/auth?token=66c181958656449fbeb904184bf8b0c4', body: req_params, verify: false)
 
			HTTParty.default_cookies.add_cookies(response.headers["set-cookie"][0], verify: false)
			HTTParty.post('http://18.220.161.97:8088/logout')
			
		# end	
	end

	private

	def set_user		
		mobile_number = session[:mobile_number]
		@user = User.find_by(mobile_number: mobile_number)
	end	

end

class ControllerApi
	include HTTParty_with_cookies
end	

