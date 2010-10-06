require 'ffi/hunspell/hunspell'

module FFI
  module Hunspell
    class Dictionary

      def initialize(affix_path,dict_path,key=nil)
        @ptr = if key
                 Hunspell.Hunspell_create_key(affix_path,dict_path,key)
               else
                 Hunspell.Hunspell_create(affix_path,dict_path)
               end
      end

      #
      # Opens a Hunspell dictionary.
      #
      # @param [String] path
      #   The path prefix shared by the `.aff` and `.dic` files.
      #
      # @yield [dict]
      #   The given block will be passed the Hunspell dictionary.
      #
      # @yieldparam [Dictionary] dict
      #   The opened dictionary.
      #
      # @return [Dictionary]
      #   If no block is given, the open dictionary will be returned.
      #
      def self.open(path)
        dict = self.new("#{path}.aff","#{path}.dic")

        if block_given?
          yield dict

          dict.destroy
          return nil
        else
          return dict
        end
      end

      #
      # The encoding of the dictionary file.
      #
      # @return [String]
      #   The encoding of the dictionary file.
      #
      def encoding
        Hunspell.Hunspell_get_dic_encoding(self)
      end

      #
      # Adds a word to the dictionary.
      #
      # @param [String] word
      #   The word to add to the dictionary.
      #
      def add(word)
        Hunspell.Hunspell_add(self,word.to_s)
      end

      def add_affix(word,example)
        Hunspell.Hunspell_add_affix(self,word.to_s,example.to_s)
      end

      alias << add

      #
      # Removes a word from the dictionary.
      #
      # @param [String] word
      #   The word to remove.
      #
      def remove(word)
        Hunspell.Hunspell_remove(self,word.to_s)
      end

      alias delete remove

      #
      # Checks if the word is validate.
      #
      # @param [String] word
      #   The word in question.
      #
      # @return [Boolean]
      #   Specifies whether the word is valid.
      #
      def check(word)
        Hunspell.Hunspell_spell(self,word.to_s) != 0
      end

      #
      # Finds the stems of a word.
      #
      # @param [String] word
      #   The word in question.
      #
      # @return [Array<String>]
      #   The stems of the word.
      #
      def stem(word)
        stem_ptr = FFI::MemoryPointer.new(:pointer)
        count = Hunspell.Hunspell_stem(self,stem_ptr,word.to_s)
        stem_ptr = stem_ptr.get_pointer(0)

        return (0...count).map do |i|
          stem_ptr.get_pointer(i).get_string(0)
        end
      end

      #
      # Suggests alternate spellings of a word.
      #
      # @param [String] word
      #   The word in question.
      #
      # @return [Array<String>]
      #   The suggestions for the word.
      #
      def suggest(word)
        suggestion_ptr = FFI::MemoryPointer.new(:pointer)
        count = Hunspell.Hunspell_suggest(self,suggestion_ptr,word.to_s)
        suggestion_ptr = suggestion_ptr.get_pointer(0)

        return (0...count).map do |i|
          suggestion_ptr.get_pointer(i).get_string(0)
        end
      end

      #
      # Closes the dictionary.
      #
      def destroy
        Hunspell.Hunspell_destroy(self)
      end

      #
      # Converts the dictionary to a pointer.
      #
      # @return [FFI::Pointer]
      #   The pointer for the dictionary.
      #
      def to_ptr
        @ptr
      end

    end
  end
end
