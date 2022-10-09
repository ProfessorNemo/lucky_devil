# frozen_string_literal: true

# хелпер, для населения базы нужным количеством рандомных вопросов
module MySpecHelper
  def generate_questions(number)
    number.times do
      FactoryBot.create(:question)
    end
  end
end

# Это строка для подключения метода к тестам
RSpec.configure do |c|
  c.include MySpecHelper
end
