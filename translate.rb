class Translator
    def initialize(words_file, grammar_file)
      @words_file = words_file
      @grammar_file = grammar_file
      @words = Hash.new
      f = File.open(words_file)
      while (line = f.gets)
        line_array = line.split(", ")
        if line =~ /^.+, [A-Z]{3}, ([A-Z].+:.+, ){0,}([A-Z].+:.+)$/
          for i in 0..line_array.size-1
            if (i == 0)
              @words[line_array[0]] = Array.new(2)
              @words[line_array[0]][1] = Hash.new
              @words[line_array[0]][0] = line_array[1]
            end
            if (i >= 2)
              if i == line_array.size-1
                @words[line_array[0]][1][line_array[i].split(":")[0]] = line_array[i].split(":")[1].delete("\n")
              else
                @words[line_array[0]][1][line_array[i].split(":")[0]] = line_array[i].split(":")[1]
              end
            end
          end
        end
      end
      f.close

      @grammar = Hash.new
      f = File.open(grammar_file)
      while (line = f.gets)
        if line =~ /^.+: ([A-Z]{3}(\{[0-9]\}){0,1}, )+[A-Z]{3}(\{[0-9]\}){0,1}$/
          lang = line.split(":")[0]
          line_array = line.split(": ")[1].split(", ")
          @grammar[lang] = Array.new(line_array.size-1)
          for i in 0..line_array.size-1
            if i == line_array.size-1
              @grammar[lang][i] = line_array[i].delete("\n")
            else
              @grammar[lang][i] = line_array[i]
            end
          end

          for i in 0..@grammar[lang].size-1
            if @grammar[lang][i] =~ /^...\{[0-9]\}$/
              num = @grammar[lang][i][4].to_i
              for j in i+1..num-1
                @grammar[lang].insert(j, @grammar[lang][i][0..2])
              end
              @grammar[lang][i] = @grammar[lang][i][0..-(4)]
            end
          end
          
        end
      end
      f.close
      #puts @grammar
      #puts @words
    end
    # part 1
    #@@translator = Translator.new("#{__dir__}/../test/public/inputs/words3.txt", "#{__dir__}/../test/public/inputs/grammar3.txt")
    #@@translator2 = Translator.new("#{__dir__}/../test/public/inputs/words2.txt", "#{__dir__}/../test/public/inputs/grammar2.txt")
    #@translator3 = Translator.new("#{__dir__}/../test/public/inputs/words3.txt", "#{__dir__}/../test/public/inputs/grammar3.txt")

  
    def updateLexicon(inputfile)
      f = File.open(inputfile)
      while (line = f.gets)
        line_array = line.split(", ")
        for i in 0..line_array.size-1
          if line =~ /^.+, [A-Z]{3}, ([A-Z].+:.+, ){0,}([A-Z].+:.+)$/
            if (i == 0)
              if  (@words.has_key?(line_array[0]) && @words[line_array[0]][0] != line_array[1]) || (!@words.has_key?(line_array[0]))
                @words[line_array[0]] = Array.new(2)
                @words[line_array[0]][1] = Hash.new
                @words[line_array[0]][0] = line_array[1]
              end
            end

            if (i >= 2)
              if !@words[line_array[0]][1].has_key?(line_array[i].split(":")[0]) || 
                (@words[line_array[0]][1].has_key?(line_array[i].split(":")[0]) && 
                (@words[line_array[0]][1][line_array[i].split(":")[0]]).empty? == true)
                if i == line_array.size-1
                  @words[line_array[0]][1][line_array[i].split(":")[0]] = line_array[i].split(":")[1].delete("\n")
                else
                  @words[line_array[0]][1][line_array[i].split(":")[0]] = line_array[i].split(":")[1]
                end
              end
            end
          end
        end
      end
      f.close
      #puts @words
    end
  
    def updateGrammar(inputfile)
      f = File.open(inputfile)
      while (line = f.gets)
        if line =~ /^.+: ([A-Z]{3}(\{[0-9]\}){0,1}, )+[A-Z]{3}(\{[0-9]\}){0,1}$/
          lang = line.split(":")[0]
          line_array = line.split(": ")[1].split(", ")
          if !@grammar.has_key?(lang)
            @grammar[lang] = Array.new(line_array.size-1)
          end
          for i in 0..line_array.size-1
            if !@grammar[lang].include?(line_array[i])
              if i == line_array.size-1
                @grammar[lang][i] = line_array[i].delete("\n")
              else
                @grammar[lang][i] = line_array[i]
              end
            end
          end
        end
      end
      f.close
      #puts @grammar
    end

    # part 2
  
    def generateSentence(language, struct)
      sentence = []
      if struct.is_a?(Array)
        for i in 0..struct.size-1
          @words.each do |key, value|
            if language == "English"
              if value[0] == struct[i]
                sentence[sentence.size] = key
                break
              end
            else
              if value[0] == struct[i] && value[1].has_key?(language)
                sentence[sentence.size] = value[1][language]
                break
              end
            end
          end
        end
        #print sentence
        if sentence.size != struct.size
          return nil
        else
          return sentence.join(" ")
        end
      end

      if struct.is_a?(String) && @grammar.has_key?(struct)
        for i in 0..@grammar[struct].size-1
          @words.each do |key, value|
            if language == "English"
              if value[0] == @grammar[struct][i]
                sentence[sentence.size] = key
                break
              end
            else
              if value[0] == @grammar[struct][i] && value[1].has_key?(language)
                sentence[sentence.size] = value[1][language]
                break
              end
            end
          end
        end
        #print sentence
        if sentence.size != @grammar[struct].size || sentence.include?("")
          return nil
        else
          return sentence.join(" ")
        end
      end
    end

    def checkGrammar(sentence, language)
      line_array = sentence.split(" ")
      grammar_array = []
      count = 0

      if @grammar[language].nil?
        return nil
      end

      if line_array.size != @grammar[language].size
        return false
      end

      for i in 0..line_array.size-1
        @words.each do |key, value|
          if (language == "English")
            if key == line_array[count]
              grammar_array[count] = value[0]
              count = count + 1
              break
            end
          else
            if value[1].value?(line_array[count])
              grammar_array[count] = value[0]
              count = count + 1
              break
            end
          end
        end
      end
      
      check = true
      for i in 0..grammar_array.size-1
        if grammar_array[i] != @grammar[language][i]
          check = false
        end
      end
      return check
    end

  
    def changeGrammar(sentence, struct1, struct2)
      line_array = sentence.split(" ")
      count = 0

      struct1_array = []
      struct2_array = []
      if struct1.is_a?(String)
        if !@grammar.has_key?(struct1)
          return nil
        end
        for i in 0..@grammar[struct1].size-1
          struct1_array[i] = @grammar[struct1][i]
        end
        for i in 0..struct1_array.size-1
          if struct1_array[i] =~ /^...\{[0-9]\}$/
            num = struct1_array[i][4].to_i
            for j in i+1..num-1
              struct1_array.insert(j, struct1_array[i][0..2])
            end
            struct1_array[i] = struct1_array[i][0..-(4)]
          end
        end
      else
        struct1_array = struct1
      end

      if struct2.is_a?(String)
        if !@grammar.has_key?(struct2)
          return nil
        end
        for i in 0..@grammar[struct2].size-1
          struct2_array[i] = @grammar[struct2][i]
        end
        for i in 0..struct1_array.size-1
          if struct2_array[i] =~ /^...\{[0-9]\}$/
            num = struct2_array[i][4].to_i
            for j in i+1..num-1
              struct2_array.insert(j, struct2_array[i][0..2])
            end
            struct2_array[i] = struct2_array[i][0..-(4)]
          end
        end
      else
        struct2_array = struct2
      end
      if struct1_array.sort != struct2_array.sort || line_array.size != struct1_array.size
        return nil
      end
      for i in 0..struct2_array.size-1
        if struct1_array[i] != struct2_array[i]
          for j in 0..struct1_array.size-1
            if struct1_array[j] == struct2_array[i]
              temp1 = struct1_array[i]
              struct1_array[i] = struct1_array[j]
              struct1_array[j] = temp1

              temp2 = line_array[i]
              line_array[i] = line_array[j]
              line_array[j] = temp2
              break
            end
          end
        end
      end
      

      return line_array.join(" ")
    end
    # part 3
  
    def changeLanguage(sentence, language1, language2)
      if sentence.nil? || language1.nil? || language2.nil?
        return nil
      end
      line_array = sentence.split(" ")
      lan_array = []
      change = 0

      for i in 0..line_array.size-1
        @words.each do |key, value|
          if language1 == "English"
            if line_array[i] == key
              lan_array[i] = value[1][language2]
              change = change + 1
            end

          else
            if value[1].value?(line_array[i])
              if language2 == "English"
                lan_array[i] = key
                change = change + 1
              else
                lan_array[i] = value[1][language2]
                change = change + 1
              end
            end
          end

        end
      end
      if change != line_array.size
        return nil
      else
        return lan_array.join(" ")
      end
    end
  
    def translate(sentence, language1, language2)
      if sentence.nil? || language1.nil? || language2.nil?
        return nil
      end
      temp1 = changeLanguage(sentence, language1, language2)
      if (temp1 == nil)
        return nil
      end
      temp2 = changeGrammar(temp1, language1, language2)
      if temp2 == nil
        return nil
      end
      return temp2
    end
  end
