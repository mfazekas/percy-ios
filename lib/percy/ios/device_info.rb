module Percy
  class IOS
    class DeviceInfo
      attr_reader :name, :code

      def initialize(name, code)
        @name = name
        @code = code
      end

      def retina_multiplier()
        case code
        when /iPhone5,[1-4]/
          2
        when /iPad4,[1-3]/
          2
        when /iPad5,[3-4]/
          2
        else
          raise "Unknown device model :#{code}"
        end
      end

      def self.find(name, code)
        self.new(name, code)
      end

    end
  end
end