# frozen_string_literal: true

require "base64"

# Pure helpers for the TestFlight lane. No Fastlane dependency, so
# `ruby fastlane/ci_support_test.rb` can run without a Mac or gems.
module CiSupport
  class Error < StandardError; end

  APP_IDENTIFIER = "com.qiudeteng.lingyunui"
  PROFILE_NAME = "lingyun-ui-flutter-appstore"
  DIST_MARKERS = ["Apple Distribution", "iPhone Distribution", "iOS Distribution"].freeze

  module_function

  def normalize_private_key(raw)
    text = raw.to_s.dup
    text = text.gsub("\\n", "\n") unless text.include?("\n")
    text = text.strip
    text += "\n" unless text.end_with?("\n")
    unless text.include?("-----BEGIN PRIVATE KEY-----") || text.include?("-----BEGIN EC PRIVATE KEY-----")
      raise Error, "APP_STORE_CONNECT_API_KEY_P8 必须是完整的 .p8 PEM，包含 -----BEGIN PRIVATE KEY-----。不要只填 Key ID，也不要填 Base64。"
    end
    text
  end

  def decode_base64_blob(raw, label:)
    text = raw.to_s.strip
    text = text.sub(/\Adata:[^,]*,/, "")
    text = text.delete("\"'").gsub(/\s+/, "")
    raise Error, "#{label} 是空的。" if text.empty?

    text += "=" * ((4 - text.length % 4) % 4)
    bytes = Base64.strict_decode64(text)
    if bytes.bytesize < 200 || !bytes.start_with?("\x30".b)
      raise Error, "#{label} 解码后不像 PKCS#7/PKCS#12 文件。请对证书或描述文件本身做 Base64，不要对密码做 Base64。"
    end
    bytes
  rescue ArgumentError
    raise Error, "#{label} 不是有效的 Base64。"
  end

  def marketing_version(pubspec_text, override)
    chosen = override.to_s.strip
    chosen = chosen.delete_prefix("v")
    if chosen.empty?
      line = pubspec_text.to_s.lines.find { |entry| entry.match?(/\Aversion:\s*/) }
      raise Error, "example/pubspec.yaml 缺少 version:。" if line.nil?

      chosen = line.split(":", 2).last.strip.split("+", 2).first.strip
    end
    unless chosen.match?(/\A\d+(?:\.\d+){0,2}\z/)
      raise Error, "营销版本必须是 1、1.2 或 1.2.3，当前是 #{chosen.inspect}。请改 workflow 的 build_name，或 example/pubspec.yaml 的 version。"
    end
    chosen
  end

  def build_number(override, run_number)
    chosen = override.to_s.strip
    chosen = run_number.to_s.strip if chosen.empty?
    unless chosen.match?(/\A[1-9]\d*\z/)
      raise Error, "构建号必须是正整数，当前是 #{chosen.inspect}。留空会使用 GitHub Actions 的 run number，也可以在 Run workflow 里填写 build_number。"
    end
    chosen
  end

  def distribution_identities(find_identity_output)
    find_identity_output.to_s.scan(/"([^"]+)"/).flatten.select do |name|
      DIST_MARKERS.any? { |marker| name.include?(marker) }
    end
  end

  def prefer_distribution_identity(names)
    list = Array(names)
    list.find { |name| name.include?("Apple Distribution") } ||
      list.find { |name| name.include?("iPhone Distribution") || name.include?("iOS Distribution") }
  end

  def identity_team_suffix(name)
    name.to_s[/\(([A-Z0-9]{10})\)\s*\z/, 1]
  end

  def assert_same_team!(identity, team_id)
    suffix = identity_team_suffix(identity)
    return identity if suffix.nil? || suffix == team_id

    raise Error, "p12 属于团队 #{suffix}，但目标 Team ID 是 #{team_id}。请换用同一团队的 Apple Distribution 证书。"
  end

  def signing_certificate_kind(name)
    return "Apple Distribution" if name.include?("Apple Distribution")
    return "iPhone Distribution" if name.include?("iPhone Distribution") || name.include?("iOS Distribution")

    raise Error, "无法识别证书类型：#{name}"
  end

  def normalize_team_id(raw)
    team_id = raw.to_s.strip.upcase
    return "" if team_id.empty?
    unless team_id.match?(/\A[A-Z0-9]{10}\z/)
      raise Error, "APPLE_TEAM_ID 应是 10 位 Developer Team ID（例如 AB12CD34EF），当前是 #{raw.to_s.strip.inspect}。这不是 Issuer ID。"
    end
    team_id
  end

  def team_id_from_bundle_ids_json(body, bundle_id:)
    data = body.is_a?(Hash) ? body["data"] : nil
    unless data.is_a?(Array)
      raise Error, "App Store Connect 的 bundleIds 响应缺少 data。可以改设 secret APPLE_TEAM_ID。"
    end

    row = data.find do |item|
      attrs = item.is_a?(Hash) ? item["attributes"] : nil
      attrs.is_a?(Hash) && attrs["platform"] == "IOS" && attrs["identifier"] == bundle_id
    end
    row ||= data.find do |item|
      attrs = item.is_a?(Hash) ? item["attributes"] : nil
      attrs.is_a?(Hash) && attrs["identifier"] == bundle_id
    end
    seed = row&.dig("attributes", "seedId").to_s.strip.upcase
    if seed.empty?
      raise Error, "开发者门户中找不到 Bundle ID #{bundle_id}。请确认 App Store Connect 应用「凌云UI」使用的就是这个 Bundle ID，或设置 secret APPLE_TEAM_ID。"
    end
    normalize_team_id(seed)
  end

  def profile_name(plist)
    plist.to_s[/<key>Name<\/key>\s*<string>([^<]*)<\/string>/, 1]
  end

  def profile_app_identifier(plist)
    plist.to_s[/<key>application-identifier<\/key>\s*<string>([^<]*)<\/string>/, 1]
  end

  def assert_profile!(plist, bundle_id:)
    name = profile_name(plist).to_s.strip
    app_id = profile_app_identifier(plist).to_s.strip
    raise Error, "描述文件里没有 Name。请确认 secret 里是 .mobileprovision 的 Base64，不是证书。" if name.empty?
    unless app_id == bundle_id || app_id.end_with?(".#{bundle_id}")
      raise Error, "描述文件的 application-identifier 是 #{app_id.inspect}，需要 #{bundle_id}。"
    end
    [name, app_id]
  end

  def xml_escape(text)
    text.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub('"', "&quot;")
  end

  def export_options_plist(team_id:, certificate:, profile_name:, bundle_id:)
    <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>method</key>
        <string>app-store-connect</string>
        <key>destination</key>
        <string>export</string>
        <key>signingStyle</key>
        <string>manual</string>
        <key>teamID</key>
        <string>#{xml_escape(team_id)}</string>
        <key>signingCertificate</key>
        <string>#{xml_escape(certificate)}</string>
        <key>provisioningProfiles</key>
        <dict>
          <key>#{xml_escape(bundle_id)}</key>
          <string>#{xml_escape(profile_name)}</string>
        </dict>
        <key>uploadSymbols</key>
        <true/>
        <key>manageAppVersionAndBuildNumber</key>
        <false/>
      </dict>
      </plist>
    XML
  end
end
