Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :users, only: [:create] do
  	collection do 
  		get :login
  		get :otp
  		post :authenticate_otp
  		get :login_success
  	end	
  end

end
