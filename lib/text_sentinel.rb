require 'iconv'

#
# Given a string, tell us whether or not is acceptable. Also, remove stuff we don't like
# such as leading / trailing space.
#
class TextSentinel

  attr_accessor :text

  def self.non_symbols_regexp
    /[\ -\/\[-\`\:-\@\{-\~]/m
  end

  def initialize(text, opts=nil)
    if text.present?
      @text = Iconv.new('UTF-8//IGNORE', 'UTF-8').iconv(text.dup)
    end

    @opts = opts || {}

    if @text.present?
      @text.strip! 
      @text.gsub!(/ +/m, ' ') if @opts[:remove_interior_spaces]
    end
  end

  # Entropy is a number of how many unique characters the string needs. 
  def entropy
    return 0 if @text.blank?
    @entropy ||= @text.each_char.to_a.uniq.size
  end

  def valid?    

    # Blank strings are not valid
    return false if @text.blank?

    # Entropy check if required
    return false if @opts[:min_entropy].present? and (entropy < @opts[:min_entropy])

    # We don't have a comprehensive list of symbols, but this will eliminate some noise
    non_symbols = @text.gsub(TextSentinel.non_symbols_regexp, '').size
    return false if non_symbols == 0

    # Don't allow super long strings without spaces

    return false if @opts[:max_word_length] and @text =~ /\w{#{@opts[:max_word_length]},}(\s|$)/

    # We don't allow all upper case content
    return false if @text == @text.upcase

    true
  end

end
