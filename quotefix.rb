text = ARGF.read

def substitute_expression(substitution, text)
	pattern = substitution[0]
	replacement = substitution[1]
	while pattern.match(text) 
		text = text.gsub(pattern, replacement)
	end
	return text
end

substitutions = Queue.new
ExpressionPair = Struct.new(:pattern, :replacement)

#Targets quotes which do not contain punctuation, start right before punctuation,
#exceed 200 characters, or comprise solely of a character that is either punctuation or a space
NO_PUNCTUATION_QUOTE = /([^\.\?\!])\"(([^\"\.\?\!\:]){2,200}|[^\s\"\.\!\?\:])\"([\s|\.|\!|\?|\,|\;|\:])/
substitutions << ExpressionPair.new(NO_PUNCTUATION_QUOTE, '\1&&\2&&\4')

#Targets quotes that start right before punctuation (therefore @ the beginning of a sentence)
#and continues until the end of a sentence (where there is punctuation)
PUNCTUATION_QUOTE_PUNCTUATION = /([\.|\!|\?|\:])\s(")([^\"]{1,700})(\"\s*(\.|\?|\!|\,)|(\.|\?|\!)\s*\")/
substitutions << ExpressionPair.new(PUNCTUATION_QUOTE_PUNCTUATION, '\1 &&\3&&\5\6')

#Targets any remaining quotes that do not excede the length of 400 characters
REMAINING_QUOTES = /(")([^\"]{1,400})((\")\s*(\.|\?|\!|\,)|(\.|\?|\!)\s*\")/
substitutions << ExpressionPair.new(REMAINING_QUOTES, '&&\2&&\5\6')

#These target errors relating to either broken quotations or missing punctuation within quotations
#-------------------------------------------------------------------------------------------
MISSING_PUNCTUATION = /\"([^\"]{1,400}[^\.\?\!])\s*\"[^\.\?\!]/
substitutions << ExpressionPair.new(MISSING_PUNCTUATION, '&&\1&&')

MISSING_BEGINNING_QUOTATION = /([\.\!\?])\s([^\.]+)(\")([\.|\?|\!])/
substitutions << ExpressionPair.new(MISSING_BEGINNING_QUOTATION, '&&\2&&\5\6')

MISSING_ENDING_QUOTATION = /([\.|\?|\!|\:]\s*)(\")([^\.\?\!]+)(.)/
substitutions << ExpressionPair.new(MISSING_ENDING_QUOTATION, '\1&&\3&&\4')

LONE_QUOTATION = /([^\.]+)(")([^\.]+\.)/
substitutions << ExpressionPair.new(LONE_QUOTATION, '\1\3')

#Replaces the double ampersand (&&) with a quotation mark
AMPERSAND_SUBSTITUTION = /\&\&/
substitutions << ExpressionPair.new(AMPERSAND_SUBSTITUTION, '"') 

while !substitutions.empty?
	text = substitute_expression(substitutions.pop, text)
end

print(text)
