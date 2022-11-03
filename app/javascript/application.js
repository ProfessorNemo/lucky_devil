import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"

import 'bootstrap/js/dist/dropdown'
import './scripts/autohide_flash'

Rails.start()
Turbolinks.start()
ActiveStorage.start()