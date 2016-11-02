module Percy
  class IOS
    module TestSummaryProcessor
      def self.read(path)
        test_result = Plist::parse_xml(path)
        device = dig(test_result,"RunDestination", "TargetDevice", "ModelName")
        screenshots = []
        _extract_screenshots(test_result.fetch("TestableSummaries"), screenshots)
        screenshots = _filter_screenshots(screenshots)
        {device: device, screenshots: screenshots}
      end

      private

      def self.dig(hash, *array)
        array.inject(hash) { |act, item| act[item] if act }
      end

      # Extract all screenshots from xcode testsummaries.plist
      def self._extract_screenshots(nodes, result, ident = 0, titles = [])
        existing_titles = {}
        nodes.each_with_index do |node, node_idx|
          Percy.logger.debug {  "#{'  '*ident} IDX:#{node_idx} title:#{node["Title"]}" }
          if node["Title"]
            title = node["Title"]
            if existing_titles[title]
              existing_titles[title] += 1
              title = "#{title}#{existing_titles[title]}"
            else
              existing_titles[title] = 1
            end
            ntitles = titles + [title]
          else
            raise "Unexpected plist: parent had Title, but we dont" unless titles.empty? || titles[0].has_key?(:test_id)
            ntitles = [{test_id:node["TestIdentifier"]}]
          end
          _extract_screenshots(node["Tests"], result, ident+1, ntitles) if node["Tests"]
          _extract_screenshots(node["Subtests"], result, ident+1, ntitles) if node["Subtests"]
          _extract_screenshots(node["ActivitySummaries"], result, ident+1, ntitles) if node["ActivitySummaries"]
          _extract_screenshots(node["SubActivities"], result, ident+1, ntitles) if node["SubActivities"]
          if node["HasScreenshotData"]
            Percy.logger.debug { "#{'  '*ident} title:#{ntitles.join("/")} UUID:#{node["UUID"]}" } 
            result.push(path: ntitles.dup, UUID: node["UUID"])
          end
        end
      end

      def self._filter_screenshots(screenshots)
        screenshots.map do |screenshot|
          if screenshot[:path][1].start_with? "io.percy/"
            path = screenshot[:path][0][:test_id].chomp('()') + "/" + screenshot[:path][1].dup
            path.slice!('io.percy/')
            { orinal_path: screenshot[:path], path:path, UUID:screenshot[:UUID] }
          end
        end.compact
      end
    end
  end
end