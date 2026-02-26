#!/bin/bash
# LPMS Deployment Script
# Author: Thanva Phupingbut
# Usage: sudo bash deploy.sh

# ===============================
# 1. Update System
# ===============================
echo "Updating system..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y git nginx certbot python3-certbot-nginx nodejs npm

# ===============================
# 2. Clone LPMS Repo
# ===============================
echo "Cloning LPMS repo..."
git clone https://github.com/allitem/LPMS.git /var/www/lpms
cd /var/www/lpms

# ===============================
# 3. Setup Backend
# ===============================
echo "Setting up backend..."
cd backend
npm install
# Create .env
cat > .env <<EOL
PORT=5000
DB_HOST=localhost
DB_USER=lpmsuser
DB_PASS=lpmspass
API_KEY=YOUR_API_KEY
SECRET_KEY=YOUR_SECRET_KEY
EOL
npm run build
npm run start &

# ===============================
# 4. Setup Frontend
# ===============================
echo "Setting up frontend..."
cd ../frontend
npm install
npm run build
# Move build to Nginx web root
sudo rm -rf /var/www/html/*
sudo cp -r build/* /var/www/html/

# ===============================
# 5. Setup Nginx
# ===============================
echo "Configuring Nginx..."
sudo bash -c 'cat > /etc/nginx/sites-available/lpms <<EOL
server {
    listen 80;
    server_name yourdomain.com;

    root /var/www/html;
    index index.html index.htm;

    location /api/ {
        proxy_pass http://localhost:5000/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOL'
sudo ln -s /etc/nginx/sites-available/lpms /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# ===============================
# 6. Setup SSL
# ===============================
echo "Setting up SSL..."
sudo certbot --nginx -d yourdomain.com --non-interactive --agree-tos -m your-email@example.com

# ===============================
# 7. Done
# ===============================
echo "LPMS Deployment Completed!"
echo "Frontend: http://yourdomain.com"
echo "Backend API: http://yourdomain.com/api/"
