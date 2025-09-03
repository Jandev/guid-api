import { defineConfig } from 'vite'
import { resolve } from 'path'

export default defineConfig({
  define: {
    __GUID_API_URL__: JSON.stringify(process.env.GUID_API_URL || 'https://api.guid.codes')
  },
  build: {
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'index.html'),
        about: resolve(__dirname, 'about.html'),
        notfound: resolve(__dirname, '404.html')
      }
    }
  }
})