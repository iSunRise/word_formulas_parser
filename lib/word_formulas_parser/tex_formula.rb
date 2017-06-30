require 'tmpdir'
require 'securerandom'

module WordFormulasParser
  class TexFormula
    MIN_FORMULA_COMPLEXITY = 4.0

    attr_reader :tex_text

    def initialize(tex_text)
      @tex_text = tex_text
    end

    # Finding formula and equations in tex text
    def find_formulas
      # for formulas like $ %tex_formula% $
      regexp_1 = /\$(.*?)\$/im

      # for formulas like \begin{equation*}
      #                    %tex_formula%
      #                   \end{equation*}
      regexp_2 = /\\begin{equation\*}(.+?)\\end{equation\*}/im

      formulas = []

      [regexp_1, regexp_2].each do |regexp|
        @tex_text.scan(regexp) do |matches|
          matches.each do |formula|
            next if formula_complexity(formula) < MIN_FORMULA_COMPLEXITY
            formulas << formula
          end
        end
      end

      formulas
    end

    # Renders expression to PNG image using <tt>latex</tt> and <tt>dvipng</tt>
    # returns array with paths to images
    def to_png(formulas, background = 'White', density = 700)
      images = []
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

          # deleting unused files
          ["#{sha1}.tex", "#{sha1}.aux", "#{sha1}.dvi", "#{sha1}.log"].each do |file|
            File.delete(file) if File.exist?(file)
          end

          raise ' latex converting to .png failed' unless sucess

          images << File.join(temp_path, "#{sha1}.png") if sucess
        end
      end

      images
    end

    private

    # Filter for large, big, long formulas, we dont care about small stuff
    def formula_complexity(formula)
      operations = 0

      # [\_]       - index
      # [\^]       - exponentiation
      # \\underset - put something under another symbol
      # \\overset  - put something over another symbol
      formula.scan(/[\_]|[\^]|\\underset|\\overset/) do |match|
        operations += 0.5
      end

      # \+                          - addition
      # \-                          - subtraction
      # \/, \\div, \\frac, \\times  - division
      # \*, \\bullet, \\cdot, \\ast - multiplication
      # \\pm, \\mp                  - ±, ∓
      # \\otimes                    - ⊗
      # \\circ                      - ∘
      operations += formula.scan(/[\+\-\/\*]|\\div|\\frac|\\bullet|\\cdot|\\ast|\\pm|\\mp|\\times|\\otimes|\\circ/).count

      operations
    end
  end
end
