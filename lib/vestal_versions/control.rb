module VestalVersions
  module Control
    def self.included(base)
      base.alias_method_chain :create_version?, :control
      base.alias_method_chain :update_version?, :control
    end

    def skip_version
      @skip_version = true
      begin
        yield if block_given?
        save
      ensure
        @skip_version = nil
      end
    end

    def skip_version!
      @skip_version = true
      begin
        yield if block_given?
        save!
      ensure
        @skip_version = nil
      end
    end

    def skip_version?
      !!@skip_version
    end

    def merge_version
      @merge_version = true
      begin
        yield
      ensure
        @merge_version = nil
      end
      save
    end

    def merge_version!
      @merge_version = true
      begin
        yield
      ensure
        @merge_version = nil
      end
      save!
    end

    def merge_version?
      !!@merge_version
    end

    def append_version
      @merge_version = true
      begin
        yield
      ensure
        @merge_version = nil
      end
      @append_version = true
      begin
        saved = save
      ensure
        @append_version = nil
      end
      saved
    end

    def append_version!
      @merge_version = true
      begin
        yield
      ensure
        @merge_version = nil
      end
      @append_version = true
      begin
        saved = save!
      ensure
        @append_version = nil
      end
      saved
    end

    def append_version?
      !!@append_version
    end

    private
      def create_version_with_control?
        !skip_version? && !merge_version? && !append_version? && create_version_without_control?
      end

      def update_version_with_control?
        append_version?
      end
  end
end
