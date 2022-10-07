# frozen_string_literal: true

module GamesHelper
  # Этот метод будет рисовать удобный ярлычок для показа статуса игры
  # Используем стандартные bootstrap-овский класс `label`
  def game_label(game)
    status_styles =
      case game.status
      when :in_progress then 'bg-warning'
      when :timeout     then 'bg-secondary'
      when :fail        then 'bg-danger'
      else                   'bg-success'
      end

    if game.status == :in_progress && current_user == game.user
      link_to content_tag(:span, t("game_statuses.#{game.status}")),
              game_path(game),
              class: "link-secondary text-decoration-none #{status_styles} rounded p-1"
    else
      content_tag :span, t("game_statuses.#{game.status}"), class: "#{status_styles} rounded p-1"
    end
  end
end
