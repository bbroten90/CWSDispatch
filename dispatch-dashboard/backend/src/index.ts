// src/index.ts
import app from './app';
import pool from './config/backend-database-connection';
import { setupLogger } from './utils/logger';

// Initialize logger
setupLogger();

const PORT = process.env.PORT || 3001;

const server = app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  
  // Test database connection on startup
  pool.query('SELECT NOW()', (err: Error | null, res: any) => {
    if (err) {
      console.error('Database connection error:', err.message);
    } else {
      console.log('Database connected successfully at:', res.rows[0].now);
    }
  });
});

// Handle graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    pool.end().then(() => {
      console.log('Database pool has ended');
      process.exit(0);
    });
  });
});

export default server;
