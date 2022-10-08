# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    around_action :switch_locale

    private

    # https://guides.rubyonrails.org/i18n.html#managing-the-locale-across-requests
    def switch_locale(&action)
      logger.debug "* Accept-Language: #{request.env['HTTP_ACCEPT_LANGUAGE']}"
      locale = extract_locale_from_accept_language_header
      logger.debug "* Locale set to '#{locale}'"
      I18n.with_locale(locale, &action)
    end

    def extract_locale_from_accept_language_header
      request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
    end
  end
end
