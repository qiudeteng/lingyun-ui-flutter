# frozen_string_literal: true

require "base64"
require "json"
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
