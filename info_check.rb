Dir.glob("laz/*.laz").each {|path|
  print "checking #{path}\n"
  system "pdal info --summary #{path} > /dev/null"
}

