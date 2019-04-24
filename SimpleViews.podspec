Pod::Spec.new do |spec|
    spec.name = "SimpleViews"
    spec.swift_versions = "5.0"
    spec.version  = "0.1.8"
    spec.summary  = "A framework to simplify complex views, like UITableView."
    spec.homepage = "https://github.com/matadesigns/simpleviews"
    spec.license  = 'MIT'
    spec.authors  = { "Nicholas Mata" => 'nicholas@matadesigns.net' }
  
    spec.platform     = :ios, "9.0"
    spec.requires_arc = true
    spec.source       = { git: "https://github.com/matadesigns/simpleviews.git", :tag => spec.version }
    spec.source_files = "SimpleViews/SimpleViews/**/*.{h,swift}"
  end
