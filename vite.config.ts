import { defineConfig } from 'vite'

export default defineConfig({
  define: {
    __GUID_API_URL__: JSON.stringify(process.env.GUID_API_URL || 'https://api.guid.codes')
  },

  root: 'src',                    // Source files are in src/
  build: {
    outDir: '../dist',            // Build output goes to dist/
    emptyOutDir: true,
    rollupOptions: {
      input: {
        main: 'src/index.html',   // Main entry point
        about: 'src/about.html',  // About page
        404: 'src/404.html'       // 404 page
      }
    }
  },
  server: {
    open: '/index.html'
  }
})