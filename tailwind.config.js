/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./public/**/*.html'],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        'primary': '#3b82f6',
        'primary-dark': '#1d4ed8',
        'accent-cyan': '#06b6d4',
        'accent-violet': '#8b5cf6',
        'deep-bg': '#0B0F19',
        'surface-dark': '#151B2B',
      },
      fontFamily: {
        'display': ['Manrope', 'sans-serif'],
        'body': ['Noto Sans', 'sans-serif'],
      },
      backgroundImage: {
        'hero-glow': 'radial-gradient(circle at center, rgba(56, 189, 248, 0.15) 0%, rgba(139, 92, 246, 0.05) 40%, transparent 100%)',
      },
      animation: {
        'float': 'float 6s ease-in-out infinite',
        'float-delayed': 'float 6s ease-in-out 3s infinite',
        'pulse-slow': 'pulse 4s cubic-bezier(0.4, 0, 0.6, 1) infinite',
      },
      keyframes: {
        float: {
          '0%, 100%': { transform: 'translateY(0)' },
          '50%': { transform: 'translateY(-20px)' },
        },
      },
    },
  },
  plugins: [],
}
