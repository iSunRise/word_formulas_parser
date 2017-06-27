require 'word_formulas_parser/version'
require 'word_formulas_parser/docx'

module WordFormulasParser
  class DocxParser
    def self.detect_and_parse(input_file_path, output_file_path)
      extencion = File.extname(input_file_path)
      case extencion
      when /\.docx/i
        then Docx.parse(input_file_path, output_file_path)
      end
    end
  end
end
