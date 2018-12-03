class UsersController < ApplicationController

	before_action :set_user, only: [:authenticate_otp]

	def create		
		user = User.where(mobile_number: params[:mobile_number]).first_or_initialize
		unless user.valid?
			flash[:danger] = "Invalid Mobile number"
			redirect_to login_users_path
			return
		end	

		user.generate_otp
		user.save!
		session[:mobile_number] = params[:mobile_number]
		#todo: send the otp to mobile number through sms provider
		redirect_to otp_users_path
	end	

	def login
		session.merge!(params.permit(:cid, :ap, :ssid, :rid, :site, :t))				
	end	

	def otp		
	end

	def authenticate_otp		
		otp = params[:otp]		
		unless @user.verify_otp?(otp)
			flash[:danger] = "Otp invalid or expired"
			redirect_to otp_users_path
			return
		end

		res = APControllerApi.authorize_user({ cid: session[:cid], ap: session[:ap], ssid: session[:ssid],rid: session[:rid], site: session[:site], t: session[:t], time: "1800" })
		if res.parsed_response['success'] == false
			redirect_to login_failed_users_path and return
		end	
		# trigger event
		redirect_to login_success_users_path
	end

	def login_success

	end	

	def login_failed

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

	def self.authorize_user(authriozation_params)
	  api = APControllerApi.new 
	  login_params = { name: ENV['ap_controller_username'], password: ENV['ap_controller_password']}
		response = api.post("#{BASE_URL}/login", body: login_params, verify: false)		

		site_name = authriozation_params[:site]
		csrf_token = response.parsed_response["value"]
		api.post("#{BASE_URL}/extportal/#{site_name}/auth?token=#{csrf_token}", body: authriozation_params, verify: false)				
	end	
end	

