Pod::Spec.new do |s|
  s.name             = 'lingyun_ui_flutter'
  s.version          = '0.4.0'
  s.summary          = 'iOS LYPage host: Size Class, system tabs, split, arrangement.'
  s.description      = <<-DESC
Native page host for lingyun_ui_flutter. Layout follows horizontal size class
and the view's available bounds. System TabView and NavigationSplitView are
always compiled. ArrangementView, UIArrangementViewController, and
reservedRegions are compiled only when LY_IOS_27_1_SDK=1 at pod install
(iOS 27.1 SDK).
                       DESC
  s.homepage         = 'https://github.com/qiudeteng/lingyun-ui-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'qiudeteng' => 'qiudeteng@qq.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '16.0'
  s.swift_version = '5.0'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'SWIFT_VERSION' => '5.0',
  }

  # iOS 27.1 symbols are not in older SDKs. Opt in only when the active
  # Xcode contains that SDK, then reinstall pods:
  #   LY_IOS_27_1_SDK=1 pod install
  if ENV['LY_IOS_27_1_SDK'] == '1'
    s.pod_target_xcconfig['OTHER_SWIFT_FLAGS'] = '$(inherited) -D LY_IOS_27_1_SDK'
  end
end
