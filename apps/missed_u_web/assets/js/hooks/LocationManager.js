function buildCallbacks(pushEvent) {
    return {
        success: position => {
            const latitude = position.coords.latitude;
            const longitude = position.coords.longitude;

            pushEvent('location:updated-position', {latitude, longitude});
        },
        error: () => {
            console.log('Error getting location');
        }
    };
}

export default {
    mounted() {

        const { success, error } = buildCallbacks((event, payload, callback) => {
            this.pushEvent(event, payload, callback)
        });

        if (navigator.permissions) {
            navigator.permissions.query({name: 'geolocation'}).then((PermissionStatus) => {
                if('granted' === PermissionStatus.state) {
                    navigator.geolocation.watchPosition(success, error);
                }
            })
        }

        window.addEventListener('track-location', (event) => {
            if (navigator.geolocation) {
                navigator.geolocation.watchPosition(success, error);
            }
        });
    }
};