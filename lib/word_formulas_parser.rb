require 'word_formulas_parser/version'
require 'word_formulas_parser/docx'

module WordFormulasParser
    def self.detect_and_parse(input_file_path, output_file_path)
      test_requirements!
      extencion = File.extname(input_file_path)
      case extencion
      when /\.docx/i
        then Docx.parse(input_file_path, output_file_path)
      end
    end

    def self.test_requirements!
      raise 'LibbreOffice is not installed' unless system("which soffice")

      raise 'writer2latex is not installed' unless system("which w2l")

      raise 'latex is not installed' unless system("which latex")

      raise 'dvipng is not installed' unless system("which dvipng")
    end
end
