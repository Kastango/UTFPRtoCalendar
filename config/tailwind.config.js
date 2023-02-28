const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
      colors: {
        'true-gray': '#A1A1A1',
        'true-yellow': '#FBBC04',
        'almost-black': 'rgba(31,31,31,1.0)'
      },
      keyframes: {
        headShake: {
          '0%': {
            transform: 'translateX(0)',
          },
          '6.5%': {
            transform: 'translateX(-2px) rotateY(-2deg)',
          },

          '18.5%': {
            transform: 'translateX(3px) rotateY(3deg)',
          },

          '31.5%': {
            transform: 'translateX(0px) rotateY(0deg)',
          },

          '43.5%': {
            transform: 'translateX(2px) rotateY(2deg)',
          },
          '50%': {
            transform: 'translateX(0)',
          },
        },
      },
      animation: {
        headShake: 'headShake 2s infinite',
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
  ]
}
