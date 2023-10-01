require 'tmpdir'

GLOB = "laz/*.laz"
DST = "dst"
DST_LAZ = "merged_laz"
SRC_LAZ = "laz"

## 試行錯誤のあとをあえて残しておきます

## NOT USED
def convert_part(token)
  system <<-EOS
py3dtiles convert --srs_in 3857 --srs_out 4978 --out #{DST}/#{token} #{SRC_LAZ}/#{token}*.laz
  EOS
end

## NOT USED
def merge
  system <<-EOS
py3dtiles merge --output-tileset #{DST}/ #{DST}
  EOS
end

def create_hash
  hash = Hash.new {|h, k| h[k] = 0}
  Dir.glob(GLOB) {|path|
    token = File.basename(path, ".laz")[0..4]
    hash[token] += 1
  }
  hash
end

def merge_laz(token)
  Dir.mktmpdir {|tmpdir|
    system <<-EOS
pdal merge #{SRC_LAZ}/#{token}*.laz #{tmpdir}/#{token}.laz;
mv #{tmpdir}/#{token}.laz #{DST_LAZ}/#{token}.laz
    EOS
  }
end

def convert
  system <<-EOS
py3dtiles convert --srs_in 3857 --srs_out 4978 --out #{DST} #{DST_LAZ}/*.laz
  EOS
end

def upload
  system <<-EOS
ipfs add --recursive --progress #{DST}
  EOS
end

## MAIN
system "ulimit -n 65536"
system "ulimit -n"
system "rm -rv #{DST}"
system "rm -rv #{DST_LAZ}; mkdir #{DST_LAZ}"
hash = create_hash
sorted_keys = hash.keys.sort {|a, b| hash[a] <=> hash[b]}
##sorted_keys = sorted_keys[0..2] ##
n = sorted_keys.size
#hash.each {|token, count|
i = 0
sorted_keys.each {|token|
  i += 1
  print "#{Time.now}: [#{i}/#{n}] #{token} (#{hash[token]})\n"
  #convert_part(token)
  merge_laz(token)
}
#merge
convert
upload

## The classic convesion command
def NO_USE 
system <<-EOS
py3dtiles convert srs_in 3857 --srs_out 4978 --out #{DST} #{SRC_LAZ}/*.laz
EOS
end
