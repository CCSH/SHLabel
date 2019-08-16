Pod::Spec.new do |s|
    s.name         = "SHLabel"
    s.version      = "1.0.0"
    s.summary      = "基于Label添加文字局部点击"
    s.license      = "MIT"
    s.authors      = { "CSH" => "624089195@qq.com" }
    s.platform     = :ios, "8.0"
    s.requires_arc = true
    s.homepage     = "https://github.com/CCSH/SHLabel"
    s.source       = { :git => "https://github.com/CCSH/SHLabel.git", :tag => s.version }
    s.source_files = "SHLabel/*.{h,m}"
end