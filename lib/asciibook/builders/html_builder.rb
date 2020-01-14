module Asciibook
  module Builders
    class HtmlBuilder < BaseBuilder
      def initialize(book)
        super
        @build_dir = File.expand_path('build/html', @base_dir)
        @theme_dir = File.expand_path('../../../../themes/default/html', __FILE__)
      end

      def build
        FileUtils.mkdir_p @build_dir
        FileUtils.rm_r Dir.glob("#{@build_dir}/*")

        generate_pages
        copy_assets
      end
    end
  end
end
