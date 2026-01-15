import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
// import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
    plugins: [
        laravel({
            input: ["resources/css/app.css", "resources/js/app.js"],
            refresh: true,
        }),
        // tailwindcss(),
    ],
    server: {
        host: "0.0.0.0",
        https: false,
        port: parseInt(process.env.VITE_INTERNAL_PORT || 5173),
        origin: process.env.VITE_DEV_SERVER_URL || "http://localhost:5173",
        watch: {
            ignored: ["**/storage/framework/views/**"],
            usePolling: true,
        },
        hmr: {
            host: "localhost",
            protocol: "ws",
        },
        cors: true,
    },
});
