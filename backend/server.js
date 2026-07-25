const express = require('express');
const cors = require('cors');
require('dotenv').config();

const aiRoutes = require('./routes/ai_routes');
const adminRoutes = require('./routes/admin_routes');
const vaultRoutes = require('./routes/vault_routes');
const marketplaceRoutes = require('./routes/marketplace_routes');

const app = express();
const PORT = process.env.PORT || 5000;

// Global Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' }));

// Health Check Endpoint
app.get('/api/health', (req, res) => {
  res.json({
    status: 'online',
    service: 'BeMind AI Backend API',
    timestamp: new Date().toISOString()
  });
});

// API Routes
app.use('/api/ai', aiRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/vault', vaultRoutes);
app.use('/api/marketplace', marketplaceRoutes);

// Start Server
app.listen(PORT, () => {
  console.log(`=================================================`);
  console.log(` BeMind AI Backend API Server running on port ${PORT}`);
  console.log(` Health Check: http://localhost:${PORT}/api/health`);
  console.log(` Admin Model Switcher: http://localhost:${PORT}/api/admin/model`);
  console.log(`=================================================`);
});
