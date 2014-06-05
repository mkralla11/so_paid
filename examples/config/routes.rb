HerbsSupplementsOsuEdu::Application.routes.draw do

  get "/redirect_from_hop" => :redirect_from_hop, :controller=>:payments

  resources :payments do
    member do
      get :confirm
    end
  end

end