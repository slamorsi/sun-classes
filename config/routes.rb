SUNClasses::Application.routes.draw do
  resources :students
  resources :sun_classes do
    collection do
      post :import 
      post :clear
    end
    resources :students
  end
  root :to => 'sun_classes#index'
end
