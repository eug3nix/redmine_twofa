  match 'account/twofa/confirm', :to => 'account#twofa_confirm', :via => :get
  match 'account/twofa/resend', :to => 'account#twofa_resend', :via => :post
  match 'account/twofa', :to => 'account#twofa', :via => [:get, :post]
  match 'my/twofa/activate/init', :controller => 'twofa', :action => 'activate_init', :via => :post
  match 'my/twofa/:scheme/activate/init', :controller => 'twofa', :action => 'activate_init', :via => :post
  match 'my/twofa/:scheme/activate/confirm', :controller => 'twofa', :action => 'activate_confirm', :via => :get
  match 'my/twofa/:scheme/activate', :controller => 'twofa', :action => 'activate', :via => [:get, :post]
  match 'my/twofa/:scheme/deactivate/init', :controller => 'twofa', :action => 'deactivate_init', :via => :post
  match 'my/twofa/:scheme/deactivate/confirm', :controller => 'twofa', :action => 'deactivate_confirm', :via => :get
  match 'my/twofa/:scheme/deactivate', :controller => 'twofa', :action => 'deactivate', :via => [:get, :post]
  match 'my/twofa/select_scheme', :controller => 'twofa', :action => 'select_scheme', :via => :get
  match 'my/twofa/backup_codes/init', :controller => 'twofa_backup_codes', :action => 'init', :via => :post
  match 'my/twofa/backup_codes/confirm', :controller => 'twofa_backup_codes', :action => 'confirm', :via => :get
  match 'my/twofa/backup_codes/create', :controller => 'twofa_backup_codes', :action => 'create', :via => [:get, :post]
  match 'my/twofa/backup_codes', :controller => 'twofa_backup_codes', :action => 'show', :via => [:get]
  match 'users/:user_id/twofa/deactivate', :controller => 'twofa', :action => 'admin_deactivate', :via => :post