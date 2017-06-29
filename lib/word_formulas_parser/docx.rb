require 'tmpdir'
require 'digest'
require 'json'
require 'securerandom'

module WordFormulasParser
  class Docx
    class << self
      def process(input_file_path, output_file_path)
        begin
          parse(input_file_path, output_file_path)
        rescue => ex
          puts "#{ex.class}:#{ex}"
        end
      end

      def parse(input_file_path, output_file_path)
        # for formulas like $ %tex_formula% $
        regexp_1 = /\$(.*?)\$/im

        # for formulas like \begin{equation*}
        #                    %tex_formula%
        #                   \end{equation*}
        regexp_2 = /\\begin{equation\*}(.+?)\\end{equation\*}/im

        outdir, docx_file_name = File.split(input_file_path)

        # create .odt from .docx
        sucess = system("soffice --headless --convert-to odt --outdir #{outdir} \
          #{input_file_path}")
         # binding.pry
        raiser(' soffice converting from .docx to .odt failed', sucess)

        # get name without .docx
        extention = File.extname(docx_file_name)
        name = docx_file_name.gsub(extention, '')

        # create path to odt and tex files
        odt_file_path = File.expand_path(name + ".odt", outdir)
        tex_file_path = File.expand_path(name + ".tex", outdir)

        # create .tex from .odt
        sucess = system("w2l #{odt_file_path} #{tex_file_path}")
        raiser(' w2l converting from .odt to .tex failed', sucess)

        # create array with formulas
        tex_text = File.read(tex_file_path)

        formulas = []
        formulas += formulas_finder(regexp_1, tex_text)
        formulas += formulas_finder(regexp_2, tex_text)

        images = formulas_to_png(formulas)

        result = []
        images.length.times do |i|
          result << {img_path: images[i], text: formulas[i]}
        end

        File.open(output_file_path, 'w') do |f|
          f.write(JSON.pretty_generate(result))
        end

        # delete .odt and .tex files
        [odt_file_path, tex_file_path].each do |file|
          File.delete(file) if File.exists?(file)
        end
      end

      private


      def raiser(error, sucess)
        raise error unless sucess
      end

      def formulas_finder(regexp, tex_text)
        formulas = []
        tex_text.scan(regexp) do |match_arr|
          match_arr.each { |formula|  formulas << formula }
        end
        formulas
      end

      # Renders expression to PNG image using <tt>latex</tt> and <tt>dvipng</tt>
      # returns array with paths to images
      def formulas_to_png(formulas, background = 'White', density = 700)
        arr_images = []
        temp_path = Dir.mktmpdir

        Dir.chdir(temp_path) do
          formulas.each do |formula|
            # random file_name for .tex
            sha1 = SecureRandom.hex

            # .tex file that must be converted to .png
            File.open("#{sha1}.tex", 'w') do |f|
              f.write("\\documentclass{article}\n \
                       \\usepackage{mathtext}\n \
                       \\usepackage[T2A]{fontenc}\n \
                       \\usepackage[utf8]{inputenc}\n \
                       \\usepackage[english, russian]{babel}\n \
                       \\usepackage{amsmath,amssymb}\n \
                       \\begin{document}\n \
                       \\thispagestyle{empty}\n \
                         $$ #{formula} $$\n \
                       \\end{document}\n")
            end

            # create .png from .tex
            sucess = system("latex -interaction=nonstopmode #{sha1}.tex && \
                            dvipng -q -T tight -bg #{background} \
                            -D #{density.to_i} -o #{sha1}.png #{sha1}.dvi")
            raiser(' latex converting to .png failed', sucess)

            # deleting unused files
            ["#{sha1}.tex", "#{sha1}.aux", "#{sha1}.dvi", "#{sha1}.log"].each do |file|
              File.delete(file) if File.exist?(file)
            end

            # arr with paths to images
            arr_images << File.join(temp_path, "#{sha1}.png") if sucess
          end
        end

        return arr_images
      end

    end
  end
end
