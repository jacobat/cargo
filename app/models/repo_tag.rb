class RepoTag
	attr_reader :tag_string

	TAG_REGEX = %r{(((.*?)/)?(.*?)/)?(.*?):(.*)}

	def initialize(tag_string)
		@tag_string = tag_string
	end

	def registry_host
		match[3]
	end

	def username
		match[4]
	end

	def name
		match[5]
	end

	def tag
		match[6]
	end

	def local?
		username.nil?
	end

	def name_tag
		"#{name}:#{tag}"
	end

	def to_s
		@tag_string
	end

	def missing?
		@tag_string == '<none>:<none>'
	end

	def match
		tag_string.match(TAG_REGEX)
	end
end
