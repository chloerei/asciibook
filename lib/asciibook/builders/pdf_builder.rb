module Asciibook
  module Builders
    class PdfBuilder
      def initialize(book)
        @book = book
        @base_dir = @book.options[:base_dir]
        @build_dir = File.join(@base_dir, 'build/pdf')
        @theme_dir = File.expand_path('../../../../themes/default/pdf', __FILE__)
      end

      def build
        FileUtils.mkdir_p @build_dir
        FileUtils.rm_r Dir.glob("#{@build_dir}/*")

        generate_pages
        copy_assets
        generate_header_footer
        generate_pdf
      end

      def generate_pages
        layout = Liquid::Template.parse(File.read(File.join(@theme_dir, 'layout.html')))
        @book.pages.each do |page|
          File.open(File.join(@build_dir, page.path), 'w') do |file|
            file.write layout.render({
              'book' => @book.to_hash,
              'page' => page.to_hash
            })
          end
        end
      end

      def copy_assets
        Dir.glob('**/*.{jpg,png,gif,mp3,mp4,ogg,wav}', File::FNM_CASEFOLD, base: @base_dir).each do |path|
          # ignore build dir assets
          if !File.join(@base_dir, path).start_with?(@build_dir)
            copy_file(path, @base_dir, @build_dir)
          end
        end

        Dir.glob('**/*.{jpb,png,gif,svg,css,js}', File::FNM_CASEFOLD, base: @theme_dir).each do |path|
          copy_file(path, @theme_dir, @build_dir)
        end
      end

      def copy_file(path, src_dir, dest_dir)
        src_path = File.join(src_dir, path)
        dest_path = File.join(dest_dir, path)
        FileUtils.mkdir_p File.dirname(dest_path)
        FileUtils.cp src_path, dest_path
      end

      def generate_header_footer
        layout = Liquid::Template.parse <<~EOF
          <!DOCTYPE html>
          <html>
            <head>
              <script>
                function subst() {
                    var vars = {};
                    var query_strings_from_url = document.location.search.substring(1).split('&');
                    for (var query_string in query_strings_from_url) {
                        if (query_strings_from_url.hasOwnProperty(query_string)) {
                            var temp_var = query_strings_from_url[query_string].split('=', 2);
                            vars[temp_var[0]] = decodeURI(temp_var[1]);
                        }
                    }
                    var css_selector_classes = ['page', 'frompage', 'topage', 'webpage', 'section', 'subsection', 'date', 'isodate', 'time', 'title', 'doctitle', 'sitepage', 'sitepages'];
                    for (var css_class in css_selector_classes) {
                        if (css_selector_classes.hasOwnProperty(css_class)) {
                            var element = document.getElementsByClassName(css_selector_classes[css_class]);
                            for (var j = 0; j < element.length; ++j) {
                                element[j].textContent = vars[css_selector_classes[css_class]];
                            }
                        }
                    }
                }
              </script>
              <style>
                html, body {
                  margin: 0;
                  padding: 0;
                }
              </style>
            </head>
            <body onload="subst()">
              {{ content }}
            </body>
          </html>
        EOF

        File.open(File.join(@build_dir, 'header.html'), 'w') do |file|
          file.write layout.render('content' => File.read(File.join(@theme_dir, 'header.html')))
        end

        File.open(File.join(@build_dir, 'footer.html'), 'w') do |file|
          file.write layout.render('content' => File.read(File.join(@theme_dir, 'footer.html')))
        end
      end

      def generate_pdf
        command = ['wkhtmltopdf']
        command << '--header-html' << File.expand_path('header.html', @build_dir)
        command << '--footer-html' << File.expand_path('footer.html', @build_dir)
        command << '--margin-top' << '10'
        command << '--margin-left' << '10'
        command << '--margin-right' << '10'
        command << '--margin-bottom' << '10'

        @book.pages.each do |page|
          if page.node.is_a?(Asciidoctor::Section) && page.node.sectname == 'toc'
            command << 'toc' << '--xsl-style-sheet' << File.join(@theme_dir, 'toc.xsl')
          else
            command << page.path
          end
        end
        command << 'output.pdf'
        command << { chdir: @build_dir }
        system *command
      end
    end
  end
end
