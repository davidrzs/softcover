module Polytexnic
  module Commands
    module Generator
      extend self

      def generate_directory(name)
        thor = Thor::Shell::Basic.new

        puts "generating directory: #{name}"

        overwrite_all = false

        FileUtils.mkdir name unless File.exists?(name)
        Dir.chdir name

        template_files.each do |path|
          next if path =~ /\/.$|\/..$/

          (cp_path = path.dup).slice! template_dir + "/"
          display_path = File.join name, cp_path

          if File.exists?(cp_path) && !overwrite_all
            res = thor.ask "#{display_path} already exists. " \
              "Overwrite? (yes,no,all):"

            overwrite = case res
            when /y|yes/ then true
            when /n|no/ then false
            when /a|all/ then
              overwrite_all = true
              true
            end

            next unless overwrite
          else
            puts display_path
          end

          if File.directory?(path)
            FileUtils.mkdir cp_path unless File.exists?(cp_path)
          else
            FileUtils.cp path, cp_path
          end
        end

        Dir.chdir ".."
        puts "Done. Please update book.yml"
      end

      def template_dir
        File.expand_path File.join File.dirname(__FILE__), "../template"
      end

      def template_files
        Dir.glob File.join(template_dir, "**/*"), File::FNM_DOTMATCH
      end

      def verify!
        generated_files = Dir.glob("**/*",File::FNM_DOTMATCH).map do |f| 
          File.basename(f) 
        end

        Polytexnic::Commands::Generator.template_files.each do |file|
          raise unless generated_files.include?(File.basename(file))
        end
      end
    end
  end
end
