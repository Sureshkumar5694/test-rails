class UsersController < ApplicationController

	before_action :set_user, only: [:authenticate_otp]

	def create		
		user = User.where(mobile_number: params[:mobile_number]).first_or_initialize
		if user.valid?
			flash[:error] = "Invalid Mobile number"
			redirect_to login_users_path
		end	

		user.generate_otp
		user.save!
		session[:mobile_number] = params[:mobile_number]
		#todo: send the otp to mobile number through sms provider
		redirect_to otp_users_path
	end	

	def login
		session.merge!(params)		
	end	

	def otp		
	end

	def authenticate_otp		
		otp = params[:otp]
		
		unless @user.verify_otp?(otp)
			flash[:error] = "Otp invalid or expired"
			return
		end

		APControllerApi.authorize_user
		redirect_to login_success_users_path
	end

	def login_success

	end	

	private

	def set_user		
		mobile_number = session[:mobile_number]
		@user = User.find_by(mobile_number: mobile_number)
	end	

end

class APControllerApi
	include HTTParty_with_cookies
	BASE_URL = ENV['ap_controller_url']

	def self.authorize_user
	  api = APControllerApi.new 
	  req_params = { name: ENV['ap_controller_username'], password: ENV['ap_controller_password']}
		response = api.post("#{BASE_URL}/login", body: req_params, verify: false)		
            
		req_params = { cid: session[:cid], ap: session[:ap], ssid: session[:ssid],rid: session[:rid], site: session[:site], t: session[:t], time: "120" }
		site_name = session[:site_name]
		csrf_token = response.parsed_response["value"]
		response = api.post("#{BASE_URL}/extportal/#{site_name}/auth?token=#{csrf_token}", body: req_params, verify: false)
		
		csrf_token = response.parsed_response["value"]	
		api.post("#{BASE_URL}/logout?token=#{csrf_token}")
	end	
end	

