class User < ActiveRecord::Base

	validates :phone,:presence => true, :numericality => true, :length => { :minimum => 10, :maximum => 11 }

	def is_otp_expired?
  	otp_expires_at.nil?|| otp_expires_at.past?
	end

	def generate_otp
		otp =(0...6).map { rand(9) }.join
		update(otp: otp, otp_expires_at: DateTime.current + 2.minutes)
	end	

	def verify_otp?(otp)
		otp == otp && !is_otp_expired?
	end	

end
