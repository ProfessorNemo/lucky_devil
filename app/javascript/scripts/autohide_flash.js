setInterval(function() {
    if (document.getElementById('flash')) {
        setTimeout(() => {
            const flash = document.getElementById('flash')

            flash.style.display = 'none'
        }, 7500)
    }
}, 1000)