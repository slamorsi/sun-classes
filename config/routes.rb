SUNClasses::Application.routes.draw do
  resources :students
  resources :sun_classes do
    collection { post :import }
    resources :students
  end
  root :to => 'sun_classes#index'
end
