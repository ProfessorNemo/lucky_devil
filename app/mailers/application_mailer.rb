# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials.dig(:mail, :mail_from)

  layout 'mailer'
end
