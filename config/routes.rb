SUNClasses::Application.routes.draw do
  resources :students
  resources :classes
  root :to => 'sun_classes#index'
end
