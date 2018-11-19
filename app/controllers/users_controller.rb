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
		# session[:cid] = params[:cid]	
		# session[:ap] = params[:ap]
		# session[:ssid] = params[:ssid]
		# session[:t] = params[:t]
		# session[:rid] = params[:rid]
		# session[:site] = params[:site]

		session[:clientMac] = params[:clientMac]
		session[:radiusSvrIp] = "192.168.1.48"
		session[:target] = params[:target]
	end	

	def otp
		
	end

	def authenticate_otp
		otp = params[:otp]
		# unless @user.verify_otp?(otp)
			# req_params = { name: 'admin', password: 'ajira12345' }
			# response = HTTParty.post('http:controller_ip/login', body: req_params)
	    
	  #   HTTParty.default_cookies.add_cookies(response.headers["set-cookie"][0])
			# req_params = { cid: params[:cid], ap: session[:ap], ssid: session[:ssid],rid: session[:rid], site: session[:site], time: "1800" }
			# response = HTTParty.post('http:controller_ip/extportal/site_name/auth', body: req_params)
 
			# HTTParty.default_cookies.add_cookies(response.headers["set-cookie"][0])
			# HTTParty.post('https://controller_server_ip:https_port/logout')
			
			req_params = { username: "admin", password: "ajira12345",clientMac: session[:clientMac], radiusSvrIp: session[:radiusSvrIp] }
			res = HTTParty.post("http://192.168.1.151/portal/auth", body: req_params)
			puts "response ==============> #{res}"
		# end	
	end

	private

	def set_user		
		mobile_number = session[:mobile_number]
		@user = User.find_by(mobile_number: mobile_number)
	end	

end