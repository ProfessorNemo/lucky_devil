# frozen_string_literal: true

module GamesHelper
  # Этот метод будет рисовать удобный ярлычок для показа статуса игры
  # Используем стандартные bootstrap-овский класс `label`
  def game_label(game)
    status_styles =
      case game.status
      when :in_progress then 'label-warning'
      when :timeout     then 'label-secondary'
      when :fail        then 'label-danger'
      else                   'label-success'
      end

    if game.status == :in_progress && current_user == game.user
      link_to content_tag(:span, t("game_statuses.#{game.status}")),
              game_path(game),
              class: "label #{status_styles}"
    else
      content_tag :span, t("game_statuses.#{game.status}"), class: "label #{status_styles}"
    end
  end
end
