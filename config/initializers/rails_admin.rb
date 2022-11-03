# frozen_string_literal: true

RailsAdmin.config do |config|
  config.asset_source = :sprockets
  config.parent_controller = 'Admin::BaseController'
  config.authorize_with do
    redirect_to main_app.root_path unless current_user.is_admin?
  end

  ## == Devise ==
  # Настраиваем авторизацию в админке с помощью devise
  config.authenticate_with do
    warden.authenticate! scope: :user
  end

  config.current_user_method(&:current_user)
  config.included_models = %w[Question Game User]
  config.show_gravatar = true

  config.actions do
    dashboard
    index
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app
  end
end
