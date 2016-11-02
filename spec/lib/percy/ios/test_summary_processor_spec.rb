require 'percy/ios/test_summary_processor'
require 'tempfile'

RSpec.describe Percy::IOS::TestSummaryProcessor do
  describe '#read' do
    it "reads file with no tests" do
      Tempfile.open('TestSumary.plist') do |f|
        f.write(
          <<-EOF.gsub /^\s+/, ""
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
              <key>FormatVersion</key>
              <string>1.2</string>
              <key>RunDestination</key>
              <dict>
                <key>TargetDevice</key>
                <dict>
                  <key>ModelCode</key>
                  <string>iPad4,2</string>
                  <key>ModelName</key>
                  <string>iPad Air</string>
                </dict>
              </dict>
              <key>TestableSummaries</key>
              <array>
              </array>
            </dict>
            </plist>
          EOF
        )
        f.close
        result = Percy::IOS::TestSummaryProcessor.read(f.path)
        device = result[:device]
        expect(device.name).to eq("iPad Air")
        expect(device.code).to eq("iPad4,2")
      end
    end
  end
end