# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :validatable, :rememberable, :trackable

  # имя не пустое, email валидирует Devise
  validates :name, presence: true, length: { maximum: 20 }

  # поле только булевское (лож/истина) - недопустимо nil
  validates :is_admin, inclusion: { in: [true, false] }, allow_nil: false

  # это поле должно быть только целым числом, значение nil - недопустимо
  validates :balance, numericality: { only_integer: true }, allow_nil: false

  # у юзера много игр, они удалятся из базы вместе с ним
  has_many :games, dependent: :destroy

  validate :password_complexity

  validates :email, presence: true,
                    uniqueness: true,
                    'valid_email_2/email': true

  # расчет среднего выигрыша по всем играм юзера
  def average_prize
    (balance.to_f / games.count).round unless games.count.zero?
  end

  private

  # проверка для сложности пароля
  def password_complexity
    # Regexp extracted from https://stackoverflow.com/questions/19605150/regex-for-password-must-contain-at-least-eight-characters-at-least-one-number-a
    return if password.blank? || password =~ /(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-])/

    errors.add(:password, :password_error)
  end
end
