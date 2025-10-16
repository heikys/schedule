const plugin = require("tailwindcss/plugin")

module.exports = {
    content: [
        './js/**/*.js',
        '../lib/schedule_web.ex',
        '../lib/schedule_web/**/*.ex',
        '../lib/schedule_web/**/*.heex',
        '../lib/schedule_web/**/*.html',
        '../deps/salad_ui/lib/**/*.ex'
    ],
    theme: {
        extend: {
            // Aquí puedes extender tus colores, fuentes, etc.
            // colors: require("./tailwind.colors.json"),
        },
    },
    plugins: [
        require('@tailwindcss/forms'),
        require("@tailwindcss/typography"),
        require("./vendor/tailwindcss-animate"),
        plugin(function ({ addVariant }) {
            addVariant('phx-no-feedback', ['&.phx-no-feedback', '.phx-no-feedback &'])
            addVariant('phx-click-loading', ['&.phx-click-loading', '.phx-click-loading &'])
            addVariant('phx-submit-loading', ['&.phx-submit-loading', '.phx-submit-loading &'])
            addVariant('phx-change-loading', ['&.phx-change-loading', '.phx-change-loading &'])
        })
    ]
}
