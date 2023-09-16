require 'tmpdir'

def build(zip_path)
  Dir.mktmpdir {|dir|
    system <<-EOS
unzip -d #{dir} #{zip_path}
    EOS
    las_path = "#{dir}/#{File.basename(zip_path).sub('.zip', '.las')}"
    laz_path = "laz/#{File.basename(zip_path).sub('.zip', '.laz')}"
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
