require 'chunky_png'
require 'percy'

module Percy
  class IOS
    class ScreenshotUploader
      def rects_to_erase(&block)
        @rects_to_erase = block
      end

      def upload(screenhosts_by_path_by_device)
        Percy.logger.debug { "uploading screenshots: #{screenhosts_by_path_by_device}" }
        with_percy_build do |client, build, current_build_id|
          screenhosts_by_path_by_device.each do |path, screenshots_by_device|
            images = screenshots_by_device.map do |device_name, screenshot|
              progress "loading image - #{path} #{device_name}....."
              image = _load(screenshot)
              progress "erasing image rect - #{path} #{device_name}....."
              _erase_rects(image, screenshot[:device], path)
              width = image.width
              height = image.height
              if width > 1200
                width = width / 2
                height = height / 2
              end
              device_name = device_name.gsub(' ', '-').downcase
              full_path = "/" + path + "/#{device_name}.png"
              {
                resource: Percy::Client::Resource.new(full_path, content: image.to_blob, mimetype: "image/png"),
                device_name: device_name,
                device_name_class: device_name,
                width: width,
                height: height
              }
            end
            full_path = "/"+path+".html"
            html = Percy::Client::Resource.new(full_path, is_root: true, content:_build_html(images), mimetype: "text/html")
            resources = [html] + images.map { |image_info| image_info[:resource] }
            _dbg_save_resources(resources, "/tmp/percy-dbg") if Percy.config.debug
            progress "uploading - #{path}...."
            upload_resources(resources, client, current_build_id, widths: images.map { |i| i[:width] }, name: path)
            progress "uploaded - #{path}....."
          end
        end
      end

      private

      def progress(message)
        STDOUT.write "\r#{message}"
        STDOUT.flush
      end

      def failed?
        @failed
      end

      def rescue_connection_failures(&block)
        raise ArgumentError.new('block is required') if !block_given?
        begin
          block.call
        rescue Percy::Client::ServerError,  # Rescue server errors.
            Percy::Client::PaymentRequiredError,  # Rescue quota exceeded errors.
            Percy::Client::ConnectionFailed,  # Rescue some networking errors.
            Percy::Client::TimeoutError => e
          Percy.logger.error(e)
          @enabled = false
          @failed = true
          nil
        end
      end

      def upload_resources(resources, client, current_build_id, options)
        resource_map = {}
        resources.each do |r|
          resource_map[r.sha] = r
        end

        rescue_connection_failures do
          start = Time.now
          rescue_connection_failures do
            snapshot = client.create_snapshot(current_build_id, resources, options)
            snapshot['data']['relationships']['missing-resources']['data'].each do |missing_resource|
              sha = missing_resource['id']
              client.upload_resource(current_build_id, resource_map[sha].content)
            end
            Percy.logger.debug { "All snapshot resources uploaded (#{Time.now - start}s)" }

            # Finalize the snapshot.
            client.finalize_snapshot(snapshot['data']['id'])
          end
          if failed?
            Percy.logger.error { "Percy build failed! Check log above for errors." }
            return
          end
          true
        end
      end

      def with_percy_build(&block)
        Percy.config.default_widths = [640]
        client = Percy.client
        build = Percy.create_build(client.config.repo)
        begin
          yield client, build, build['data']['id']
        ensure
          Percy.finalize_build(build['data']['id'])
        end
      end

      def _dbg_save_resources(resources, basedir)
        resources.each do |resource|
          path = File.join(basedir, resource.resource_url)
          dir_path = File.dirname(path)
          FileUtils.mkdir_p dir_path
          File.open(path, 'w') { |file| file.write(resource.content) }
        end
        Percy.logger.debug { "processed files were saved to: #{basedir} for debugging" }
      end

      def _build_html(images)
        widths = images.map { |image| image[:width] }
        raise "Error we don't support multiple devices with the same width" if widths.detect{ |width| widths.count(width) > 1 }
        media_queries = images.map do |image| 
          width = image[:width]
          "@media screen and (max-width: #{width+16}px) and (min-width: #{width}px) {" +
          images.map { |image| "img.#{image[:device_name_class]} { display: none; }" if image[:width] != width }.compact.join("\n") +
          "}"
        end
        img_tags = images.map do |image|
          %{<img src="#{image[:resource].resource_url}" width="#{image[:width]}" height="#{image[:height]}" class="#{image[:device_name_class]}"></img>}
        end
        html = %{
          <!DOCTYPE html>
          <html>
          <head>
          <style>
          #{media_queries.join("\n")}
          </style>
          </head>
          <body>
            <div data-kind="screenshots" data-os="ios">
            #{img_tags.join("\n")}
            </div>
          </body>
          </html>
        }
      end

      def _png_path(screenshot)
        File.join("Attachments","Screenshot_#{screenshot[:UUID]}.png")
      end

      def _load(screenshot)
        ChunkyPNG::Image.from_file(_png_path(screenshot))
      end

      def _color_to_chunky_png(color)
        raise "TODO: color support" unless color.nil?
        ChunkyPNG::Color::WHITE
      end

      def _erase_rects(image, device, path)
        @rects_to_erase[device, path, image.width, image.height].each do |rect|
          image.rect(rect[:x], rect[:y], rect[:x] + rect[:width], rect[:y] + rect[:height], ChunkyPNG::Color::TRANSPARENT, _color_to_chunky_png(rect[:color]))
        end
      end
    end
  end
end