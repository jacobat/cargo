require 'test_helper'

class RepoTagTest < ActiveSupport::TestCase
	class PrivateRepoTagTest < ActiveSupport::TestCase
		def setup
			@repo_tag = RepoTag.new('registry.com/bill/cargo:latest')
		end

		test "registry_host is registry.com" do
			assert_equal 'registry.com', @repo_tag.registry_host
		end

		test "username is bill" do
			assert_equal 'bill', @repo_tag.username
		end

		test "name is cargo" do
			assert_equal 'cargo', @repo_tag.name
		end

		test "tag is latest" do
			assert_equal 'latest', @repo_tag.tag
		end
	end

	class PublicRepoTagTest < ActiveSupport::TestCase
		def setup
			@repo_tag = RepoTag.new('bill/cargo:latest')
		end

		test "registry_host is empty" do
			assert_nil @repo_tag.registry_host
		end

		test "username is bill" do
			assert_equal 'bill', @repo_tag.username
		end

		test "name is cargo" do
			assert_equal 'cargo', @repo_tag.name
		end

		test "tag is latest" do
			assert_equal 'latest', @repo_tag.tag
		end
	end

	class LocalImageRepoTagTest < ActiveSupport::TestCase
		def setup
			@repo_tag = RepoTag.new('cargo:latest')
		end

		test "registry_host is empty" do
			assert_nil @repo_tag.registry_host
		end

		test "username is bill" do
			assert_nil @repo_tag.username
		end

		test "name is cargo" do
			assert_equal 'cargo', @repo_tag.name
		end

		test "tag is latest" do
			assert_equal 'latest', @repo_tag.tag
		end
	end

	class MissingRepoTagTest < ActiveSupport::TestCase
		def setup
			@repo_tag = RepoTag.new('<none>:<none>')
		end

		test "registry_host is empty" do
			assert_nil @repo_tag.registry_host
		end

		test "username is bill" do
			assert_nil @repo_tag.username
		end

		test "name is <none>" do
			assert_equal '<none>', @repo_tag.name
		end

		test "tag is <none>" do
			assert_equal '<none>', @repo_tag.tag
		end

		test "missing?" do
			assert @repo_tag.missing?
		end
	end
end
