require 'percy/ios/test_summary_processor'
require 'tempfile'
require 'plist'

RSpec.describe Percy::IOS::TestSummaryProcessor do
  describe '#read' do
    context "no tests" do
      let(:plist) {
        { FormatVersion: 1.2,
          RunDestination: {
            TargetDevice: {
              ModelCode: 'iPad4,2',
              ModelName: 'iPad Air'
            }
          },
          TestableSummaries: []}
      }
      it "reads file" do
        Tempfile.open('TestSumary.plist') do |f|
          f.write(plist.to_plist)
          f.close
          result = Percy::IOS::TestSummaryProcessor.read(f.path)
          device = result[:device]
          expect(device.name).to eq("iPad Air")
          expect(device.code).to eq("iPad4,2")
          expect(result[:screenshots]).to eq([])
        end
      end
    end
    context "with tests" do
      let(:plist) {
        { FormatVersion: 1.2,
          RunDestination: {
            TargetDevice: {
              ModelCode: 'iPad4,2',
              ModelName: 'iPad Air'
            }
          },
          TestableSummaries: [{
            Tests: [{
              TestIdentifier: 'All tests',
              Subtests: [{
                TestIdentifier: 'Foo.xctest',
                Subtests: [{
                  TestIdentifier: 'Foo',
                  Subtests: [{
                    TestIdentifier: 'Foo/foo()',
                    ActivitySummaries:[{
                      HasScreenshotData: true,
                      Title: 'foo0',
                      UUID: 'foo0'
                    }, {
                      HasScreenshotData: true,
                      Title: 'io.percy/name of snapshot',
                      UUID: 'foo'
                    }]
                  }]
                }]
              }]
            }]
          }]
        }
      }
      it "reads file" do
        Tempfile.open('TestSumary.plist') do |f|
          f.write(plist.to_plist)
          f.close
          result = Percy::IOS::TestSummaryProcessor.read(f.path)
          device = result[:device]
          expect(device.name).to eq("iPad Air")
          expect(device.code).to eq("iPad4,2")
          expect(result[:screenshots]).to eq([{
              orinal_path:[{:test_id=>"Foo/foo()"}, "io.percy/name of snapshot"],
              path: "name of snapshot",
              UUID: "foo"
            }])
        end
      end
    end
  end
end