== Usage

 node 'fai.my.domain'
 {
   class { 'fai::server':
     mirror => 'http://ftp.debian.org/debian',
     suite  => 'squeeze'
   }
 }
