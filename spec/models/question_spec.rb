# frozen_string_literal: true

RSpec.describe Question, type: :model do
  context 'validations check' do
    subject(:question) do
      described_class.new(
        text: 'В каком году была космическая одиссея 1?',
        level: 12,
        answer1: '1',
        answer2: '2',
        answer3: '3',
        answer4: '4'
      )
    end

    # убедиться, что есть валидация на присутствие текста и уровня
    it { is_expected.to validate_presence_of :level }
    it { is_expected.to validate_presence_of :text }
    # уровень включен в диапазон (0..14) ?
    it { is_expected.to validate_inclusion_of(:level).in_range(0..14) }

    # неразрешенное значение для поля level?
    it { is_expected.not_to allow_value(500).for(:level) }
    # разрешенное значение для поля level?
    it { is_expected.to allow_value(14).for(:level) }

    # подтверждение уникальности
    it { is_expected.to validate_uniqueness_of :text }
  end
end
