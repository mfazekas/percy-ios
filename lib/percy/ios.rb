require 'percy/ios/test_summary_processor'
require 'percy/ios/screenshot_uploader'
require 'plist'

module Percy
  class IOS
    attr_accessor :derived_data_dir

    CLOCK_WIDTH = 200
    STATUSBAR_HEIGHT = 24

    ScreenshotInfo = Struct.new(:width, :height, :device_name)

    def initialize
      @derived_data_dir = "./derived-data"
      @rects_to_erase = {}
      erase_rect(:clock) { |screenshot| {x: screenshot.width / 2 - CLOCK_WIDTH / 2, y:0, width: CLOCK_WIDTH, height: STATUSBAR_HEIGHT} }
    end

    def erase_rect(name, &block)
      if block
        @rects_to_erase[name] = block
      else
        @rects_to_erase.delete(name)
      end
    end

    def upload_screenshots
      test_logs_dir = File.join(derived_data_dir, "logs", "Test")
      raise "Derived data dir #{test_logs_dir} doesn't exists or empty!" unless File.directory?(test_logs_dir)
      Dir.chdir(test_logs_dir) do
        summaries = Dir["*_TestSummaries.plist"]
        raise "No test summary #{test_logs_dir}/*_TestSummaries.plist found!" if summaries.empty?

        screenhosts_by_path_by_device = {}
        summaries.each do |summary|
          screenshots = Percy::IOS::TestSummaryProcessor.read(summary)
          device = screenshots.fetch(:device)
          screenshots.fetch(:screenshots).each do |screenshot|
            screenhosts_by_path_by_device[screenshot[:path]] ||= {}
            raise "There is already a sceenshot for path:#{screenshot[:path]} device:#{device} either path names are not unique or you have multiple results from the same device" if screenhosts_by_path_by_device[screenshot[:path]][device]
            screenhosts_by_path_by_device[screenshot[:path]][device] = screenshot
          end
        end

        uploader = ScreenshotUploader.new
        uploader.rects_to_erase do |device_name, width, height|
          device = ScreenshotInfo.new(width, height, device_name)
          @rects_to_erase.values.map { |proc| proc[device] }
        end
        uploader.upload(screenhosts_by_path_by_device)
      end
    end
  end
end