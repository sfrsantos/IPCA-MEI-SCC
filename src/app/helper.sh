#update packages
#!/bin/sh
echo "Updating packages..."
npm update
echo "Packages are successful update!"

#run migrations
npx prisma migrate dev

#start application
echo "Starting application..."
npm start


