# frozen_string_literal: true

require "base64"
require "fileutils"
require "json"
require "tmpdir"
require_relative "ci_support"

failures = []

def check(failures, label)
  yield
rescue StandardError => e
  failures << "#{label}: #{e.class}: #{e.message}"
end

check(failures, "pem") do
  pem = CiSupport.normalize_private_key("-----BEGIN PRIVATE KEY-----\nABC\n-----END PRIVATE KEY-----")
  raise "missing newline" unless pem.end_with?("\n")
  escaped = CiSupport.normalize_private_key("-----BEGIN PRIVATE KEY-----\\nABC\\n-----END PRIVATE KEY-----")
  raise "escaped newlines were not expanded" unless escaped.include?("\nABC\n")
  begin
    CiSupport.normalize_private_key("AB12CD34EF")
    raise "key id was accepted"
  rescue CiSupport::Error
  end
end

check(failures, "base64") do
  raw = "\x30".b + ("A".b * 240)
  encoded = Base64.strict_encode64(raw).scan(/.{1,40}/).join("\n")
  decoded = CiSupport.decode_base64_blob("\"#{encoded}\"", label: "IOS_DISTRIBUTION_CERT_P12_BASE64")
  raise "roundtrip" unless decoded == raw
  begin
    CiSupport.decode_base64_blob(Base64.strict_encode64("hello"), label: "IOS_DISTRIBUTION_CERT_P12_BASE64")
    raise "short blob accepted"
  rescue CiSupport::Error
  end
  begin
    CiSupport.decode_base64_blob("!!!!", label: "IOS_DISTRIBUTION_CERT_P12_BASE64")
    raise "invalid base64 accepted"
  rescue CiSupport::Error
  end
end

check(failures, "version") do
  pubspec = "name: example\nversion: 1.0.0+1\n"
  raise "pubspec" unless CiSupport.marketing_version(pubspec, "") == "1.0.0"
  raise "override" unless CiSupport.marketing_version(pubspec, "v1.2.3") == "1.2.3"
  raise "build" unless CiSupport.build_number("", "17") == "17"
  raise "build override" unless CiSupport.build_number("42", "17") == "42"
  begin
    CiSupport.marketing_version(pubspec, "1.2.3-beta")
    raise "prerelease accepted"
  rescue CiSupport::Error
  end
  begin
    CiSupport.build_number("0", "1")
    raise "zero build accepted"
  rescue CiSupport::Error
  end
end

check(failures, "identity") do
  output = <<~OUT
      1) AAAA "Apple Development: Dev (ZZZZZZZZZZ)"
      2) BBBB "iPhone Distribution: Old (ABCDE12345)"
      3) CCCC "Apple Distribution: Lingyun (ABCDE12345)"
       3 valid identities found
  OUT
  names = CiSupport.distribution_identities(output)
  chosen = CiSupport.prefer_distribution_identity(names)
  raise chosen.inspect unless chosen.include?("Apple Distribution")
  CiSupport.assert_same_team!(chosen, "ABCDE12345")
  begin
    CiSupport.assert_same_team!(chosen, "QQQQQQQQQQ")
    raise "team mismatch accepted"
  rescue CiSupport::Error
  end
  raise "kind" unless CiSupport.signing_certificate_kind(chosen) == "Apple Distribution"
end

check(failures, "team json") do
  body = {
    "data" => [
      {
        "attributes" => {
          "identifier" => "com.qiudeteng.lingyunui",
          "platform" => "IOS",
          "seedId" => "ab12cd34ef"
        }
      }
    ]
  }
  team = CiSupport.team_id_from_bundle_ids_json(body, bundle_id: CiSupport::APP_IDENTIFIER)
  raise team unless team == "AB12CD34EF"
  begin
    CiSupport.normalize_team_id("not-a-team")
    raise "issuer accepted"
  rescue CiSupport::Error
  end
end

check(failures, "profile") do
  plist = <<~XML
    <key>Name</key>
    <string>lingyun-ui-flutter-appstore</string>
    <key>application-identifier</key>
    <string>AB12CD34EF.com.qiudeteng.lingyunui</string>
  XML
  name, app_id = CiSupport.assert_profile!(plist, bundle_id: CiSupport::APP_IDENTIFIER)
  raise name unless name == "lingyun-ui-flutter-appstore"
  raise app_id unless app_id.end_with?(CiSupport::APP_IDENTIFIER)
  begin
    CiSupport.assert_profile!(plist, bundle_id: "com.other.app")
    raise "wrong bundle accepted"
  rescue CiSupport::Error
  end
end

check(failures, "ios directory") do
  Dir.mktmpdir("ios-dir") do |root|
    ios = File.join(root, "example", "ios")
    fastlane = File.join(ios, "fastlane")
    dot_fastlane = File.join(ios, ".fastlane")
    runner_subdir = File.join(ios, "Runner")
    unrelated = File.join(root, "unrelated")
    unrelated_fastlane = File.join(unrelated, "fastlane")
    FileUtils.mkdir_p(File.join(ios, "Runner.xcodeproj"))
    FileUtils.mkdir_p(fastlane)
    FileUtils.mkdir_p(dot_fastlane)
    FileUtils.mkdir_p(runner_subdir)
    FileUtils.mkdir_p(unrelated_fastlane)

    ios_abs = File.expand_path(ios)
    raise "ios cwd" unless CiSupport.ios_directory(ios) == ios_abs
    raise "fastlane cwd" unless CiSupport.ios_directory("#{fastlane}/") == ios_abs
    raise ".fastlane cwd" unless CiSupport.ios_directory(dot_fastlane) == ios_abs

    # Dir.pwd (and therefore the default argument) resolves symlinks.
    # macOS TMPDIR is /var/folders -> /private/var/folders, so a string compare
    # against File.expand_path(mktmpdir) fails even though both name the project.
    same_project = lambda do |found, label|
      raise "#{label}: #{found}" unless File.realpath(found) == File.realpath(ios)
    end
    Dir.chdir(ios) { same_project.call(CiSupport.ios_directory, "default ios cwd") }
    Dir.chdir(fastlane) { same_project.call(CiSupport.ios_directory, "default fastlane cwd") }

    link_root = File.join(root, "via-link")
    File.symlink(File.join(root, "example"), link_root)
    Dir.chdir(File.join(link_root, "ios")) { same_project.call(CiSupport.ios_directory, "symlink ios cwd") }
    Dir.chdir(File.join(link_root, "ios", "fastlane")) do
      same_project.call(CiSupport.ios_directory, "symlink fastlane cwd")
    end

    expect_ios_directory_error = lambda do |start|
      CiSupport.ios_directory(start)
      raise "accepted #{start}"
    rescue CiSupport::Error => e
      expected = "请在 example/ios 下运行 bundle exec fastlane ios beta（当前目录 #{File.expand_path(start)}）。"
      raise "#{e.message.inspect} != #{expected.inspect}" unless e.message == expected
    end

    expect_ios_directory_error.call(unrelated)
    expect_ios_directory_error.call(unrelated_fastlane)
    expect_ios_directory_error.call(runner_subdir)
    expect_ios_directory_error.call(File.join(root, "example"))
    expect_ios_directory_error.call(root)

    Dir.chdir(unrelated) do
      expect_ios_directory_error.call(Dir.pwd)
    end
  end
end

check(failures, "sigh options") do
  options = CiSupport.app_store_sigh_options(team_id: "YMLG7W5FZH", output_path: "/tmp/work")
  raise "app store options conflict" if CiSupport.sigh_options_conflict?(options)
  %i[adhoc development developer_id].each do |key|
    raise "#{key} was set" if options.key?(key)
  end
  raise "platform" unless options[:platform] == "ios"
  raise "bundle" unless options[:app_identifier] == CiSupport::APP_IDENTIFIER
  raise "name" unless options[:provisioning_name] == CiSupport::PROFILE_NAME
  raise "force" unless options[:force] == true
  raise "filename" unless options[:filename] == "appstore.mobileprovision"
  raise "team" unless options[:team_id] == "YMLG7W5FZH"
  raise "output" unless options[:output_path] == "/tmp/work"
  raise "ignore name" unless options[:ignore_profiles_with_different_name] == true

  # Same rule as Fastlane 2.241 Configuration#verify_conflicts: false is set, nil is not.
  raise "false pair accepted" unless CiSupport.sigh_options_conflict?(adhoc: false, development: false)
  raise "true pair accepted" unless CiSupport.sigh_options_conflict?(adhoc: true, development: false)
  raise "omitted flagged" if CiSupport.sigh_options_conflict?(platform: "ios", force: true)
  raise "nil flagged" if CiSupport.sigh_options_conflict?(adhoc: nil, development: false)
  raise "adhoc only flagged" if CiSupport.sigh_options_conflict?(adhoc: false)
end

check(failures, "flutter pod env") do
  base = {
    "GEM_HOME" => "/tmp/vendor/bundle/ruby/3.3.0",
    "GEM_PATH" => "/tmp/vendor/bundle/ruby/3.3.0",
    "RUBYOPT" => "-r/tmp/bundler/setup",
    "RUBYLIB" => "/tmp/lib",
    "BUNDLE_GEMFILE" => "/tmp/example/ios/Gemfile",
    "BUNDLE_BIN_PATH" => "/tmp/bin/bundle",
    "BUNDLE_APP_CONFIG" => "/tmp/example/ios/.bundle",
    "PATH" => "/opt/homebrew/bin#{File::PATH_SEPARATOR}/usr/bin",
    "APP_STORE_CONNECT_KEY_ID" => "SECRET"
  }
  env = CiSupport.flutter_command_env(base, pod_bindir: "/ruby/3.3/bin")
  %w[GEM_HOME GEM_PATH RUBYOPT RUBYLIB BUNDLE_GEMFILE BUNDLE_BIN_PATH BUNDLE_APP_CONFIG].each do |key|
    raise "#{key} leaked" if env.key?(key)
  end
  raise "secret dropped" unless env["APP_STORE_CONNECT_KEY_ID"] == "SECRET"
  parts = env["PATH"].split(File::PATH_SEPARATOR)
  raise "bindir not first: #{env["PATH"]}" unless parts.first == "/ruby/3.3/bin"
  raise "homebrew lost" unless parts.include?("/opt/homebrew/bin")
  raise "duplicate bindir" unless parts.count("/ruby/3.3/bin") == 1

  again = CiSupport.flutter_command_env(env, pod_bindir: "/ruby/3.3/bin")
  raise "bindir duplicated on second pass" unless again["PATH"].split(File::PATH_SEPARATOR).count("/ruby/3.3/bin") == 1

  raise "1.17" unless CiSupport.pod_version_acceptable?("1.17.0\n")
  raise "1.16.2" unless CiSupport.pod_version_acceptable?("1.16.2")
  raise "old accepted" if CiSupport.pod_version_acceptable?("1.16.1")
  raise "noise accepted" if CiSupport.pod_version_acceptable?("1.17.0\nwarning")
end

check(failures, "export plist") do
  plist = CiSupport.export_options_plist(
    team_id: "AB12CD34EF",
    certificate: "Apple Distribution",
    profile_name: "lingyun & appstore",
    bundle_id: CiSupport::APP_IDENTIFIER
  )
  raise "method" unless plist.include?("<string>app-store-connect</string>")
  raise "manual" unless plist.include?("<string>manual</string>")
  raise "destination" unless plist.include?("<string>export</string>")
  raise "bundle" unless plist.include?("<key>#{CiSupport::APP_IDENTIFIER}</key>")
  raise "escape" unless plist.include?("lingyun &amp; appstore")
  raise "direct upload" if plist.include?("<string>upload</string>")
end

if failures.empty?
  puts "ci_support_test: ok"
  exit 0
end

warn failures.join("\n")
exit 1
