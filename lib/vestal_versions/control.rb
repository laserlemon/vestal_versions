module VestalVersions
  module Control
    def self.included(base)
      base.alias_method_chain :create_version?, :control
      base.alias_method_chain :update_version?, :control
    end

    def skip_version
      with_version_flag(@skip_version) do
        yield if block_given?
        save
      end
    end

    def skip_version!
      with_version_flag(@skip_version) do
        yield if block_given?
        save!
      end
    end

    def skip_version?
      !!@skip_version
    end

    def merge_version(&block)
      with_version_flag(@merge_version, &block)
      save
    end

    def merge_version!(&block)
      with_version_flag(@merge_version, &block)
      save!
    end

    def merge_version?
      !!@merge_version
    end

    def append_version(&block)
      with_version_flag(@merge_version, &block)
      with_version_flag(@append_version) do
        save
      end
    end

    def append_version!(&block)
      with_version_flag(@merge_version, &block)
      with_version_flag(@append_version) do
        save!
      end
    end

    def append_version?
      !!@append_version
    end

    private
      def with_version_flag(flag)
        flag = true
        begin
          yield
        ensure
          flag = nil
        end
      end

      def create_version_with_control?
        !skip_version? && !merge_version? && !append_version? && create_version_without_control?
      end

      def update_version_with_control?
        append_version?
      end
  end
end
