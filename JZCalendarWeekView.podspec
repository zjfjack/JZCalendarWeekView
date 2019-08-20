Pod::Spec.new do |s|
  s.name         = "JZCalendarWeekView"
  s.version      = "0.7.3"
  s.summary      = "Calendar Week & Day View in iOS Swift"
  s.homepage = "https://github.com/midrive/JZCalendarWeekView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Jeff Zhang" => "zekejeff@gmail.com" }
  s.platform     = :ios, "9.0"
  s.source = { :git => "https://github.com/fawxy/JZCalendarWeekView.git", :tag => s.version }
  s.source_files  = "JZCalendarWeekView/**/*.swift"
end
