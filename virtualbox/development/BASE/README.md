# APT-CACHER-NG
Creating an apt-cacher-ng proxy server can make creating images much faster by locally caching apt packages.

If you have an apt-cacher-ng server available you can create a file called "02proxy" to point to your server.  
The file "02proxy.example" shows that that should look like.  Substitute your own IP address, of course.

# TODO 
This seems incompatible with the oracle-java8-installer package.  
* maybe install oracle before copying 02proxy
* or download oracle installer by hand (wget?)