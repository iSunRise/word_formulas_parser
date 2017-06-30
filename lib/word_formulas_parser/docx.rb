module WordFormulasParser
  class Docx

    class << self

      def parse(input_file_path)
        tex_file_path = convert_docx_to_tex(input_file_path)
        tex_text = File.read(tex_file_path)

        tex_formula = WordFormulasParser::TexFormula.new(tex_text)
        formulas = tex_formula.find_formulas
        image_paths = tex_formula.to_png(formulas)

        formulas.each { |formula| formula.gsub!("\n", "") }

        result = []
        image_paths.each_with_index do |image_path, i|
          result << {img_path: image_path, text: formulas[i]}
        end

        File.delete(tex_file_path) if File.exist?(tex_file_path)

        result
      end

      private

      def convert_docx_to_tex(input_file_path)
        outdir, docx_file_name = File.split(input_file_path)

        # create .odt from .docx
        sucess = system("soffice --headless --convert-to odt --outdir #{outdir} \
                         #{input_file_path}")
        raise 'soffice converting from .docx to .odt failed' unless sucess

        # get name without .docx
        extension = File.extname(docx_file_name)
        name = docx_file_name.gsub(extension, '')

        # create path to odt and tex files
        odt_file_path = File.expand_path(name + ".odt", outdir)
        tex_file_path = File.expand_path(name + ".tex", outdir)

        # create .tex from .odt
        sucess = system("w2l -image_content ignore \
                         #{odt_file_path} #{tex_file_path}")
        File.delete(odt_file_path) if File.exist?(odt_file_path)
        raise 'w2l converting from .odt to .tex failed' unless sucess

        tex_file_path
      end

    end
  end
end
