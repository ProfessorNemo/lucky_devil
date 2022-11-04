import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"

import 'bootstrap/js/dist/dropdown'
import './scripts/autohide_flash'

Rails.start()
Turbolinks.start()
ActiveStorage.start()

$.ajax({ data: { authenticity_token: $('[name="csrf-token"]')[0].content } });

$(function() {
    console.log('Document is loaded');
});

$(document).on("turbolinks:load", function() {
    console.log('Document is loaded (turbolinks:load)');
})