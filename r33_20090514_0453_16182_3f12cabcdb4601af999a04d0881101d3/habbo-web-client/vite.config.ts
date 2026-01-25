import { defineConfig } from 'vite';
import { resolve } from 'path';

export default defineConfig({
  root: '.',
  base: './',
  publicDir: 'public',
  build: {
    outDir: 'dist',
    sourcemap: true,
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'index.html'),
      },
    },
  },
  resolve: {
    alias: {
      '@core': resolve(__dirname, 'src/core'),
      '@managers': resolve(__dirname, 'src/managers'),
      '@network': resolve(__dirname, 'src/network'),
      '@rendering': resolve(__dirname, 'src/rendering'),
      '@modules': resolve(__dirname, 'src/modules'),
      '@wasm': resolve(__dirname, 'src/wasm'),
    },
  },
  server: {
    port: 3000,
    open: true,
  },
  optimizeDeps: {
    exclude: ['assemblyscript'],
  },
});
