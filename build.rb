require 'tmpdir'

def get_las_path(dir, zip_path)
  las_path = "#{dir}/#{File.basename(zip_path).sub('.zip', '.las')}"
  unless File.exist?(las_path)
    las_path = "#{dir}/#{File.basename(zip_path).downcase.sub('.zip', '_org.las')}"
  end
  unless File.exist?(las_path)
    las_path = "#{dir}/#{File.basename(zip_path).sub('.zip', '_nocolor.las')}"
  end
  las_path
end

def build(zip_path)
  laz_path = "laz/#{File.basename(zip_path).sub('.zip', '.laz')}"
  if File.exist?(laz_path)
    $stderr.print "#{laz_path} exists. Deleting #{zip_path}\n"
    system "rm #{zip_path}"
    return
  end
  Dir.mktmpdir {|dir|
    system <<-EOS
unzip -d #{dir} #{zip_path}
    EOS
    las_path = get_las_path(dir, zip_path)
    pipeline = <<-EOS
[
  "#{las_path}",
  {
    "type": "filters.reprojection",
    "in_srs": "EPSG:6669",
    "out_srs": "EPSG:3857"
  },
  {
    "type": "filters.sample",
    "radius": 0.5
  },
  {
    "type": "writers.las",
    "filename": "#{laz_path}"
  }
]
    EOS
    File.open("#{dir}/pipeline.json", 'w') {|w| 
      w.print pipeline
    }
    system <<-EOS
pdal pipeline #{dir}/pipeline.json
    EOS
  }
end

Dir.glob("/Users/hfu/Desktop/*.zip") {|zip_path|
  build(zip_path)
}
