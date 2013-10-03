SUNClasses::Application.routes.draw do
  resources :students do
    collection do
      post :import 
      post :clear
      post :assign_all
      post :clear_all_assignments
    end
    member do
      post '/sun_class/:sun_class_id', :action => :assign, :as => :assign
      delete '/sun_class/:sun_class_id', :action => :unassign, :as => :unassign
    end
  end
  resources :sun_classes do
    collection do
      post :import 
      post :clear
    end
    resources :students
  end
  root :to => 'sun_classes#index'
end
