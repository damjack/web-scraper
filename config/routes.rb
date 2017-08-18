Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get :export_list, to: "scraper#export_list"
  root 'scraper#index'
end
