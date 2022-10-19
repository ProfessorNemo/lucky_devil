# Lucky devil (Who Wants to Be a Millionare?)

###### Ruby: `3.0.3` Rails: `6.1.6` Yarn: `1.22.19` Nodejs: `12.22.9` Language `Russian`
В рамках курса [goodprogrammer.ru](https://goodprogrammer.ru/).
###### Скриншоты приложения находятся в корневой директории "screenshots"

### Описание:

[Ruby on Rails](https://rubyonrails.org/) версия всемирно известной игры [Кто хочет стать миллионером?](https://ru.wikipedia.org/wiki/Кто_хочет_стать_миллионером).

- **15 вопросов**
- **15 уровней сложности**
- **4 подсказки**
  - 50:50
  - звонок другу
  - помощь аудитории
  - замена вопроса
- **3 несгораемые суммы**
  - `1 000`
  - `32 000`
  - `1 000 000`
- **без права на ошибку**

Вся логика, связанная с аутентификацией, регистрацией, созданием и изменением пароля
выполнена с помощью [`devise`](https://github.com/heartcombo/devise)

Восстановить пароль от учетной записи можно с помощью электронной почты (использовано 
решение [`letter_opener`](https://github.com/ryanb/letter_opener)).

Приложение покрыто тестами с использованием: `RSpec` `Capybara` `factory-bot`

Пользователи со статусом `admin` могут загружать вопросы (использовано решение [`rails_admin`](https://github.com/railsadminteam/rails_admin))



### Установка:
1. Клонируйте репозиторий
```
$ git clone git@github.com:phobco/millionaire-game.git
```

2. Установите библиотеки
```
$ bundle
```

3. Создайте базу данных и запустите миграцию (используется база данных PostgreSQL).
```
$ make initially
```

4. Загрузите тестовые вопросы
(только если не собираетесь загружать потом другие, реальные вопросы)
```
$ rails db:seed
```

5. Установите и обновите все зависимости в файле `package.json`.
```
$ yarn install && yarn upgrade
```

6. Запустите сервер
```
$ bin/dev
```

Откройте `localhost:3000` в браузере.

### Команда для запуска всех тестов:
```
$ make rspec
```

### Получить статус администратора:

Run Rails console
```
$ make c
```

Найдите `id` пользователя по `name`
```ruby
> User.pluck(:id, :name)
# => [[1, "Glebchik"]]
```
Найдите `User` по `id` и установите для атрибута `is_admin` значение `true`.
```ruby
> User.find(1).update(is_admin: true)
```

Панель администратора теперь доступна. Теперь у вас будут права администратора на
загрузку вопросов, удаление, редактирование пользователей и т.д. Пример файла с
вопросами 4-го уровня сложности хранится в директории "db". Для того, чтобы запустить
игру в полноценной реализации, необходимо подготовить 15 файлов с вопросами разного
уровня сложности (от 0 до 14-го) и загрузить их в базу.
Каждая непустая строка файла должна выглядеть так:

Текст вопроса?|Правильный ответ|Ответ 2|Ответ 3|Ответ 4
