export default {
    mounted() {
        window.addEventListener('reset-fields', (event) => {
            event.target.reset();
        });

        window.addEventListener('phx:after-submit', (event) => {
            const target = document.getElementById(event.detail.id);

            if (target.hasAttribute('data-after-submit')) {
                this.liveSocket.execJS(target, target.getAttribute('data-after-submit'))
            }
        });
    }
}