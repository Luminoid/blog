npm install
bower install
grunt buildProd
cd ..
cp -R tranquilpeak hexo-theme-tranquilpeak-built-for-production-1.11.0/
cd hexo-theme-tranquilpeak-built-for-production-1.11.0
rm -rf node_modules
rm -rf source/_bower_components
rm .git
NODE_ENV=production npm install
