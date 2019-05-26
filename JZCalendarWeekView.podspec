Pod::Spec.new do |s|
  s.name         = "JZCalendarWeekView"
  s.version      = "0.7.0"
  s.summary      = "Calendar Week & Day View in iOS Swift"
  s.homepage = "https://github.com/zjfjack/JZCalendarWeekView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Jeff Zhang" => "zekejeff@gmail.com" }
  s.platform     = :ios, "9.0"
  s.source = { :git => "https://github.com/zjfjack/JZCalendarWeekView.git", :tag => s.version }
  s.source_files  = "JZCalendarWeekView/**/*.swift"
end
