Pod::Spec.new do |spec|
    spec.name = "SimpleViews"
    spec.version = "0.0.5"
    spec.summary = "A framework to simplify complex views, like UITableView."
    spec.homepage = "https://github.com/matadesigns/simpleviews"
    spec.license = { type: 'MIT', file: 'LICENSE' }
    spec.authors = { "Nicholas Mata" => 'nicholas@matadesigns.net' }
  
    spec.platform = :ios, "9.0"
    spec.requires_arc = true
    spec.source = { git: "https://github.com/matadesigns/simpleviews.git", tag: "v#{spec.version}", submodules: true }
    spec.source_files = "SimpleViews/**/*.{h,swift}"
  end